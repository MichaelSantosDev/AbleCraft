-- UiTTS.lua (AbleCraft Text-to-Speech module; WoW Forever Beta 1.60.x)
AbleCraftDB = AbleCraftDB or UiTTSDB or {}
UiTTSDB = AbleCraftDB

local L = UiTTS_L

-- Forever reports the Mainline WOW_PROJECT_ID, so identify it by GetBuildInfo
-- instead of treating every addon in _classic_beta_ as a Classic Era addon.
local client = {}
if GetBuildInfo then
    client.version, client.build, client.date, client.interface = GetBuildInfo()
end
client.isForever = type(client.interface) == "number"
    and client.interface >= 16000 and client.interface < 16100

-- Check optional UI modules without loading them. demandLoaded=true allows
-- load-on-demand modules; excluded game types and missing modules stay false.
-- Older clients without the query API keep the existing discovery fallback.
local function IsAddonAvailable(...)
    if not (C_AddOns and C_AddOns.DoesAddOnExist) then return true end
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        local ok, exists = pcall(C_AddOns.DoesAddOnExist, name)
        if not ok then return true end
        if exists then
            if not C_AddOns.IsAddOnLoadable then return true end
            local okLoad, loadable = pcall(C_AddOns.IsAddOnLoadable, name, "0", true)
            if not okLoad or loadable then return true end
        end
    end
    return false
end

local hasTradingPost = IsAddonAvailable("Blizzard_PerksProgram",
    "Blizzard_TradingPostUI", "Blizzard_PerksProgramUI")

-- Set to true locally when diagnosing tooltip coverage issues.
-- Prints owner names, extracted lines, dedup decisions, and spoken payloads to chat.
local DEBUG_TOOLTIP = false

local function DebugTooltipLog(...)
    if not DEBUG_TOOLTIP then return end
    print("|cffaaffaa[UiTTS Tooltip]|r", ...)
end

local defaults = {
    enabled = true,
    maxLines = 12,
    useAlternateVoice = false,

    -- Custom TTS output. When useCustomTTS is false the addon inherits WoW's
    -- chat-TTS rate/volume (C_TTSSettings); when true it uses the values below.
    useCustomTTS = false,
    ttsRate = 0,     -- -10 (slow) .. 10 (fast)
    ttsVolume = 100, -- 0 .. 100

    -- Chat / event reading (UiTTS_Chat.lua). Whispers on by default; the noisier
    -- channels default off so the addon stays quiet until the user opts in.
    readWhispers = true,
    readParty = true,
    readSay = true,
    readGuild = true,
    readYell = true,
    readLoot = true,
    readTargetChange = true,

    interruptOnNew = true,
    skipSameText = true,
    minInterval = 0.15,
    debounceDelay = 0.08,

    -- Time-lock per owner (optional). 0 = disabled; text-based dedup handles most cases.
    lockSameOwnerFor = 0.0,

    readTooltips = true,
    readGameTooltip = true,
    readMinimap = true,
    readSpellbook = true,
    readTalents = true,
    readTradingPost = hasTradingPost,
    readQuestRewards = true,
    readQuestFrame = true,
    readGossipFrame = true,
    readGossipOptionsHover = true,
    readGuildRegistrar = true,
    readItemRef = true,
    readShopping = true,

    readProfessions = true,

    readGameMenu = true,
    readSettingsButtons = true,
    readSettingsTooltips = true,
    readEventToasts = true,
    readPVENewSlice = true,
    readPlayerChoice = true,
    readScenarioTrackerEvents = true,
    readUIErrors = true,
    readRaidWarning = true,
    readInfoPanels = true,
    readShopUI = true,
    readDialogueUIOptions = true,
    readXPGain = true,
    readLevelUp = true,
    debugUIReader = false,

    scanDynamicTooltips = true,
    scanInterval = 1.0,
}

local function ApplyDefaults()
    for k, v in pairs(defaults) do
        if UiTTSDB[k] == nil then UiTTSDB[k] = v end
    end
end

-- ========= Secret Values =========
local function IsSecretValue(v)
    if type(issecretvalue) == "function" then
        return issecretvalue(v)
    end
    return false
end

-- The beta can return a table whose contents cannot be indexed by addon code.
-- Checking only type(table) or wrapping the getter in pcall is insufficient.
local function CanAccessTable(v)
    if IsSecretValue(v) or type(v) ~= "table" then return false end
    if type(canaccesstable) == "function" then return canaccesstable(v) end
    return true
end

-- GetPoint() on a protected region hands back *secret* numbers. Comparing two
-- of those throws "attempt to compare a secret number value" from inside the
-- sort comparator, which aborts the entire read. Anything that is not a plain,
-- comparable number becomes nil.
local function SafeNumber(v)
    if IsSecretValue(v) then return nil end
    if type(v) ~= "number" then return nil end
    return v
end

-- Y offset of a region, or nil when it is unavailable, errors or is secret.
local function RegionY(region)
    if not region or not region.GetPoint then return nil end
    local ok, y = pcall(function() return select(5, region:GetPoint(1)) end)
    if not ok then return nil end
    return SafeNumber(y)
end

-- Sorts {text=, y=} lines top-to-bottom. Every Y is re-checked here (not just
-- at collection time) so a secret that reached the table by any other path
-- still cannot reach the comparison; such lines keep their collection order
-- and sort after the ones with a known Y.
local function SortLinesByY(lines)
    if not lines or #lines < 2 then return lines end
    for i, l in ipairs(lines) do l.__seq = i end
    table.sort(lines, function(a, b)
        local ay, by = SafeNumber(a.y), SafeNumber(b.y)
        if ay and by then
            if ay ~= by then return ay > by end
        elseif ay or by then
            return ay ~= nil
        end
        return a.__seq < b.__seq
    end)
    return lines
end

-- ========= Clean =========
local function CleanText(s)
    if IsSecretValue(s) then return nil end
    if type(s) ~= "string" then return nil end
    if s == "" then return nil end

    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("|T.-|t", "")
    s = s:gsub("|A.-|a", "")
    s = s:gsub("|H.-|h(.-)|h", "%1")
    s = s:gsub("\n+", " ")
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" then return nil end
    return s
end

local function FrameName(f)
    if not f then return nil end
    if f.GetName then
        -- pcall: Mixin Lua tables expose GetName as a C function reference
        -- that errors with "bad self" when called on the Lua table itself.
        local ok, n = pcall(f.GetName, f)
        if ok and not IsSecretValue(n) and type(n) == "string" and n ~= "" then return n end
    end
    return nil
end

-- pcall: some owner frames are Mixin tables (or carry secret/protected
-- values, e.g. nameplate aura frames) where GetParent exists as a field but
-- errors with "bad self" when invoked. Returns nil to stop the walk safely.
local function SafeGetParent(o)
    if not o or not o.GetParent then return nil end
    local ok, p = pcall(o.GetParent, o)
    if ok then return p end
    return nil
end

local function OwnerNameOrParents(owner, maxDepth)
    maxDepth = maxDepth or 6
    local o = owner
    for _ = 1, maxDepth do
        if not o then break end
        local n = FrameName(o)
        if n then return n end
        o = SafeGetParent(o)
    end
    return nil
end

-- Custom Mixin tooltips (e.g. DialogueUI's SharedTooltip) don't expose a
-- GetOwner method; they store the anchor in self.owner inside their SetOwner.
local function GetTooltipOwner(tooltip)
    if not tooltip then return nil end
    if tooltip.GetOwner then
        local ok, owner = pcall(tooltip.GetOwner, tooltip)
        if ok and owner then return owner end
    end
    if tooltip.owner then return tooltip.owner end
    return nil
end

local function OwnerLooksLikeQuest(owner)
    local o = owner
    for _ = 1, 10 do
        if not o then break end
        local n = FrameName(o)
        if type(n) == "string" and n ~= "" then
            if n:find("Quest") or n:find("QuestInfo") or n:find("QuestLog") or n:find("QuestChoice") then return true end
            if n:find("DUIQuest") or n:find("DialogueUI") then return true end
        end
        o = SafeGetParent(o)
    end
    return false
end

local function OwnerLooksLikeMinimap(owner)
    if not owner then return false end

    local o = owner
    for _ = 1, 12 do
        if not o then break end

        if o == Minimap or o == MinimapCluster then
            return true
        end
        if MinimapCluster and MinimapCluster.MinimapContainer and o == MinimapCluster.MinimapContainer then
            return true
        end

        local n = FrameName(o)
        if type(n) == "string" and n ~= "" then
            if n:find("Minimap")
                or n:find("MinimapCluster")
                or n:find("LibDBIcon")
                or n:find("BelowMinimap")
                or n:find("UIWidgetBelowMinimap")
                or n:find("MinimapButton")
                or n:find("MinimapBackdrop")
                or n:find("MinimapCompass")
            then
                return true
            end
        end

        o = SafeGetParent(o)
    end

    return false
end

local function OwnerLooksLikeProfessions(owner)
    local o = owner
    for _ = 1, 10 do
        if not o then break end
        local n = FrameName(o)
        if type(n) == "string" and n ~= "" then
            if n:find("Profession") or n:find("ProfSpec") or n:find("ProfBook")
                or n:find("Crafting") then
                return true
            end
        end
        o = SafeGetParent(o)
    end
    return false
end

-- Forever's spellbook and talent pages are children of PlayerSpellsFrame and
-- use GameTooltip. Their category switches must also recognise the owner.
local function OwnerMatchesName(owner, pattern)
    -- parentKey in Blizzard's XML does not give these pages a global name.
    -- Match the actual page object before trying named frames and their parents.
    local page
    if _G.PlayerSpellsFrame then
        if pattern == "SpellBook" then page = _G.PlayerSpellsFrame.SpellBookFrame
        elseif pattern == "Talent" then page = _G.PlayerSpellsFrame.TalentsFrame end
    end
    local o = owner
    for _ = 1, 10 do
        if not o then break end
        if page and o == page then return true end
        local n = FrameName(o)
        if n and n:find(pattern, 1, true) then return true end
        o = SafeGetParent(o)
    end
    return false
end

-- The in-game shop's own tooltips carry no "GameTooltip" identity: on retail
-- 12.x the shop is Blizzard_CatalogShop (CatalogShopFrame), whose tooltip frame
-- is anchored to a card / description inside that window.  Match by ancestry so
-- a renamed or unnamed tooltip frame is still recognised.
local function OwnerLooksLikeShop(owner)
    local o = owner
    for _ = 1, 12 do
        if not o then break end
        local n = FrameName(o)
        if type(n) == "string" and n ~= "" then
            if n:find("CatalogShop") or n:find("StoreFrame") or n:find("StoreProduct") then
                return true
            end
        end
        o = SafeGetParent(o)
    end
    return false
end

-- ========= TTS config =========
-- Returns a usable voice ID. If the selected voice type (e.g. Alternate) has no
-- voice configured in WoW, GetVoiceOptionID returns nil and SpeakText stays
-- silent — so fall back to Standard, then to the first installed voice, then 0.
local function GetSelectedVoiceID()
    -- Explicit voice picked in the options dropdown wins, if still installed.
    if UiTTSDB.voiceID ~= nil and C_VoiceChat and C_VoiceChat.GetTtsVoices then
        local voices = C_VoiceChat.GetTtsVoices()
        if type(voices) == "table" then
            for _, v in ipairs(voices) do
                if v.voiceID == UiTTSDB.voiceID then return v.voiceID end
            end
        end
    end

    if C_TTSSettings and C_TTSSettings.GetVoiceOptionID and Enum and Enum.TtsVoiceType then
        local voiceType = UiTTSDB.useAlternateVoice and Enum.TtsVoiceType.Alternate or Enum.TtsVoiceType.Standard
        local id = C_TTSSettings.GetVoiceOptionID(voiceType)
        if id ~= nil then return id end

        -- Selected type unavailable → try Standard.
        id = C_TTSSettings.GetVoiceOptionID(Enum.TtsVoiceType.Standard)
        if id ~= nil then return id end
    end

    -- Still nothing → use the first voice the client reports as installed.
    if C_VoiceChat and C_VoiceChat.GetTtsVoices then
        local voices = C_VoiceChat.GetTtsVoices()
        if type(voices) == "table" and voices[1] and voices[1].voiceID then
            return voices[1].voiceID
        end
    end
    return 0
end

local function GetChatTTSRate()
    if UiTTSDB.useCustomTTS then
        return tonumber(UiTTSDB.ttsRate) or 0
    end
    if C_TTSSettings and C_TTSSettings.GetSpeechRate then
        return C_TTSSettings.GetSpeechRate()
    end
    return 0
end

local function GetChatTTSVolume()
    if UiTTSDB.useCustomTTS then
        return tonumber(UiTTSDB.ttsVolume) or 100
    end
    if C_TTSSettings and C_TTSSettings.GetSpeechVolume then
        return C_TTSSettings.GetSpeechVolume()
    end
    return 100
end

-- Forever 1.60.1 (70245) uses the same signature as Retail 12.x:
--   C_VoiceChat.SpeakText(voiceID, text, rate, volume, allowOverlappedSpeech)
-- The Classic Era destination argument does not apply to Forever.
local function CallSpeakText(voiceID, text, rate, volume)
    if not (C_VoiceChat and C_VoiceChat.SpeakText) then return end
    C_VoiceChat.SpeakText(voiceID, text, rate, volume, false)
    return true
end

-- ========= Playback state =========
-- interruptOnNew makes every read cancel whatever is playing. Knowing that the
-- engine is still talking lets the tooltip batcher hold a late-arriving
-- comparison tooltip back instead of cutting the read already in progress.
local ttsPlaying = false
local ttsPlaybackToken = 0
local ttsStartedAt = 0
local playbackWaiters = {}

local function OnPlaybackEnded()
    if not ttsPlaying then return end
    ttsPlaying = false
    ttsPlaybackToken = ttsPlaybackToken + 1

    local waiters = playbackWaiters
    playbackWaiters = {}
    for _, cb in ipairs(waiters) do
        local ok, err = pcall(cb)
        if not ok then geterrorhandler()(err) end
    end
end

local function StopSpeaking()
    if C_VoiceChat and C_VoiceChat.StopSpeakingText then
        C_VoiceChat.StopSpeakingText()
    end
    ttsPlaying = false
    ttsPlaybackToken = ttsPlaybackToken + 1
    playbackWaiters = {}
end

local function IsSpeaking()
    return ttsPlaying
end

-- Runs cb once the current utterance ends. Queue is dropped by StopSpeaking.
local function RunAfterPlayback(cb)
    playbackWaiters[#playbackWaiters + 1] = cb
end

-- Rough upper bound on how long an utterance runs (~13 chars/second at rate 0).
-- Only a fallback deadline for when the playback events do not arrive.
local function EstimateSpeechSeconds(text)
    local secs = (#text / 13) + 3
    if secs > 90 then secs = 90 end
    return secs
end

local function MarkPlaybackStarted(text)
    ttsPlaying = true
    ttsStartedAt = GetTime()
    ttsPlaybackToken = ttsPlaybackToken + 1
    local token = ttsPlaybackToken

    if C_Timer and C_Timer.After then
        C_Timer.After(EstimateSpeechSeconds(text), function()
            if ttsPlaybackToken == token then OnPlaybackEnded() end
        end)
    end
end

local playbackFrame = CreateFrame("Frame")
-- pcall: RegisterEvent raises on an unknown event name, and the estimated
-- duration above is already enough to keep the state machine honest without it.
pcall(playbackFrame.RegisterEvent, playbackFrame, "VOICE_CHAT_TTS_PLAYBACK_FINISHED")
playbackFrame:SetScript("OnEvent", function()
    -- StopSpeakingText fires FINISHED for the utterance it just cut, and that
    -- event lands after the replacement has already started. Ignore anything
    -- arriving in the first moments of a new utterance.
    if not ttsPlaying then return end
    if (GetTime() - ttsStartedAt) < 0.25 then return end
    OnPlaybackEnded()
end)

-- Last text handed to the TTS engine by any reader; used by /uitts repeat and
-- the "repeat last" keybinding.
local lastSpokenGlobalText = nil

-- Low-level dispatch. Argument order matches the retail signature (see
-- CallSpeakText above): C_VoiceChat.SpeakText(voiceID, text, rate, volume,
-- allowOverlappedSpeech). Verified against Forever build 70245.
local function DoSpeak(text)
    if not text or text == "" then return end

    if UiTTSDB.interruptOnNew then
        StopSpeaking()
    end

    local voiceID = GetSelectedVoiceID()
    local rate = GetChatTTSRate()
    local volume = GetChatTTSVolume()

    if CallSpeakText(voiceID, text, rate, volume) then
        MarkPlaybackStarted(text)
    end
end

local function Speak(text)
    if not UiTTSDB.enabled then return end
    text = CleanText(text)
    if not text then return end
    lastSpokenGlobalText = text
    DoSpeak(text)
end

-- Speaks regardless of UiTTSDB.enabled. Used only for explicit user actions
-- (the in-game guide's speaker buttons and the on-demand keybindings) where the
-- user asked to hear something even if automatic reading is toggled off.
local function SpeakForced(text)
    text = CleanText(text)
    if not text then return end
    lastSpokenGlobalText = text
    DoSpeak(text)
end

-- ========= Tooltip text build =========
local CollectFrameText  -- forward declaration

local function BuildTextFromTooltipData(data)
    if not CanAccessTable(data) or not CanAccessTable(data.lines) then return nil end
    local out, count = {}, 0
    for _, line in ipairs(data.lines) do
        if count >= UiTTSDB.maxLines then break end
        if CanAccessTable(line) then
            local left = CleanText(line.leftText)
            local right = CleanText(line.rightText)
            if left and right then out[#out+1] = left .. " " .. right; count = count + 1
            elseif left then out[#out+1] = left; count = count + 1
            elseif right then out[#out+1] = right; count = count + 1 end
        end
    end
    if #out == 0 then return nil end
    return table.concat(out, ". ")
end

local function BuildTextFromTooltipFrameNamed(tooltip)
    if not tooltip or not tooltip.GetName then return nil end
    local name = tooltip:GetName()
    if not name then return nil end

    local out, count = {}, 0
    for i = 1, 30 do
        if count >= UiTTSDB.maxLines then break end
        local leftFS = _G[name .. "TextLeft" .. i]
        local rightFS = _G[name .. "TextRight" .. i]
        -- Tooltip text regions are contiguous; stop when neither side exists.
        if not leftFS and not rightFS then break end
        local left = leftFS and CleanText(leftFS:GetText())
        local right = rightFS and CleanText(rightFS:GetText())

        if left and right then out[#out+1] = left .. " " .. right; count = count + 1
        elseif left then out[#out+1] = left; count = count + 1
        elseif right then out[#out+1] = right; count = count + 1 end
    end

    if #out == 0 then return nil end
    return table.concat(out, ". ")
end

local function BuildTextFromTooltipRegions(tooltip)
    if not tooltip or not tooltip.GetRegions then return nil end
    local regions = { tooltip:GetRegions() }
    if #regions == 0 then return nil end

    local lines = {}
    for _, r in ipairs(regions) do
        if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.GetText then
            local t = CleanText(r:GetText())
            if t then
                lines[#lines+1] = { y = RegionY(r), text = t }
            end
        end
    end

    if #lines == 0 then return nil end
    SortLinesByY(lines)

    local out, count = {}, 0
    for _, l in ipairs(lines) do
        if count >= UiTTSDB.maxLines then break end
        out[#out+1] = l.text
        count = count + 1
    end

    if #out == 0 then return nil end
    return table.concat(out, ". ")
end

-- Custom Mixin tooltips (e.g. DialogueUI) keep FontStrings on a child frame
-- (self.Content) rather than as direct regions of the tooltip. Walk the whole
-- subtree so we still pick those up after the named/region builders find nothing.
local function BuildTextFromTooltipTree(tooltip)
    if not tooltip then return nil end
    local lines = CollectFrameText(tooltip)
    if not lines or #lines == 0 then return nil end

    SortLinesByY(lines)

    local out, count, seen = {}, 0, {}
    local maxLines = (UiTTSDB and UiTTSDB.maxLines) or 12
    for _, l in ipairs(lines) do
        if count >= maxLines then break end
        if l.text and not seen[l.text] then
            seen[l.text] = true
            out[#out + 1] = l.text
            count = count + 1
        end
    end
    if #out == 0 then return nil end
    return table.concat(out, ". ")
end

local function GetTooltipText(tooltip, data)
    local text = BuildTextFromTooltipData(data)
    if text then return text end
    text = BuildTextFromTooltipFrameNamed(tooltip)
    if text then return text end
    text = BuildTextFromTooltipRegions(tooltip)
    if text then return text end
    return BuildTextFromTooltipTree(tooltip)
end

-- ========= Allowed tooltip =========
local function IsAllowedTooltip(tooltip)
    if not UiTTSDB.readTooltips then return false end
    if not tooltip then return false end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return false end

    local owner = GetTooltipOwner(tooltip)

    if tooltip == GameTooltip then
        if UiTTSDB.readGameTooltip then return true end
        if UiTTSDB.readSpellbook and OwnerMatchesName(owner, "SpellBook") then return true end
        if UiTTSDB.readTalents and OwnerMatchesName(owner, "Talent") then return true end
        if UiTTSDB.readProfessions and OwnerLooksLikeProfessions(owner) then return true end
        if UiTTSDB.readMinimap and OwnerLooksLikeMinimap(owner) then return true end
        if UiTTSDB.readQuestRewards and OwnerLooksLikeQuest(owner) then return true end
        -- The shop borrows GameTooltip for its card / description tooltips, so
        -- readShopUI has to be honoured here too or turning readGameTooltip off
        -- silences the shop as well.
        if UiTTSDB.readShopUI and OwnerLooksLikeShop(owner) then return true end
        return false
    end

    local tname = FrameName(tooltip) or ""

    if UiTTSDB.readQuestRewards then
        if tname:find("Quest") or tname:find("QuestInfo") or tname:find("EmbeddedItem") then return true end
        if OwnerLooksLikeQuest(owner) then return true end
        -- Mixin tooltips (DialogueUI's SharedTooltip) may have no name and no
        -- owner set yet at hook time; fall back to the tooltip's own ancestry.
        if OwnerLooksLikeQuest(tooltip) then return true end
    end

    if UiTTSDB.readSpellbook and (tname:find("SpellBook") or OwnerMatchesName(owner, "SpellBook")) then return true end
    if UiTTSDB.readTalents and (tname:find("Talent") or OwnerMatchesName(owner, "Talent")) then return true end
    if UiTTSDB.readTradingPost and (tname:find("TradingPost") or tname:find("Perks") or tname:find("PerksProgram")) then return true end

    if UiTTSDB.readItemRef and tname == "ItemRefTooltip" then return true end
    if UiTTSDB.readShopping and (tname == "ShoppingTooltip1" or tname == "ShoppingTooltip2") then return true end

    -- In-game shop tooltips (Blizzard_CatalogShop / legacy Blizzard_Store).
    -- Explicitly not matched by a bare "Shop" pattern: ShoppingTooltip1/2 are
    -- equipment comparison frames owned by readShopping, not the shop UI.
    if UiTTSDB.readShopUI then
        if tname:find("CatalogShop") or tname:find("StoreTooltip") then return true end
        if OwnerLooksLikeShop(owner) then return true end
        if OwnerLooksLikeShop(tooltip) then return true end
    end

    if UiTTSDB.readMinimap and OwnerLooksLikeMinimap(owner) then return true end

    return false
end

-- ========= State per tooltip =========
local tooltipState = {}
local lastGlobalSpeakAt = 0
local lastGlobalSpokenText = nil

local function GetState(tooltip)
    local st = tooltipState[tooltip]
    if not st then
        st = { ownerKey = nil, lastText = nil, lastSpokenAt = 0, lastData = nil, batchSerial = 0 }
        tooltipState[tooltip] = st
    end
    return st
end

local function GetOwnerKey(tooltip)
    local owner = GetTooltipOwner(tooltip)
    return OwnerNameOrParents(owner, 10) or (owner and tostring(owner) or "noowner")
end

-- pcall: Mixin tooltips (Lua tables) expose IsShown as a C-function reference
-- that raises "bad self" when called on the table itself. Unknown = shown.
local function IsTooltipShown(tooltip)
    if not tooltip then return false end
    if not tooltip.IsShown then return true end
    local ok, shown = pcall(tooltip.IsShown, tooltip)
    if not ok then return true end
    return shown and true or false
end

-- ========= Multi-tooltip coalescing =========
-- Equipment comparison puts GameTooltip and ShoppingTooltip1/2 on screen at the
-- same time, and each frame fires its own OnShow / OnTooltipSet*. Every read
-- used to be scheduled per tooltip, so with interruptOnNew each new read called
-- StopSpeakingText on the previous one: the engine kept restarting and never
-- got past the first line of any of them. All tooltips seen inside one debounce
-- window are now merged into a single utterance, spoken once, in screen order
-- (hovered item first, then the equipped items it is compared against).
local pendingSet = {}          -- [tooltip] = true
local pendingOrder = {}        -- insertion-ordered tooltips
local pendingScheduled = false
local pendingDeadline = 0
local pendingStartedAt = 0

-- Hard cap on how long a batch may keep growing while new tooltips arrive, so a
-- tooltip that re-fires continuously can never postpone the read indefinitely.
local BATCH_MAX_WAIT = 0.30

-- Bumped once per spoken batch. A tooltip whose contribution is unchanged since
-- the batch that was just spoken is dropped from the next one, so pressing Shift
-- on an already-read item speaks only the comparison, not the item again.
local batchSerial = 0
local lastBatchKey, lastBatchText, lastBatchAt = nil, nil, 0

local function IsShoppingTooltip(tooltip)
    local n = FrameName(tooltip)
    return (n and n:find("^ShoppingTooltip") ~= nil) or false
end

-- A comparison tooltip is normally SetOwner'd to another tooltip, but some flows
-- anchor it to a plain button. Only pull an owner into the batch when it really
-- is a tooltip, or we would read the whole owning panel instead.
local function LooksLikeTooltipFrame(frame)
    if not frame then return false end
    if frame.GetNumLines then return true end
    local n = FrameName(frame)
    return (n and n:find("Tooltip") ~= nil) or false
end

-- Comparison tooltips are SetOwner'd to the tooltip they compare against, so the
-- owner link identifies the group no matter which member triggered the batch.
-- Pulls in the siblings that are on screen but did not fire an event this round.
local function ExpandComparisonGroup(order)
    local list, inList = {}, {}
    local primaries = {}

    for _, tt in ipairs(order) do
        list[#list + 1] = tt
        inList[tt] = true
        if IsShoppingTooltip(tt) then
            local owner = GetTooltipOwner(tt)
            if owner and LooksLikeTooltipFrame(owner) then primaries[owner] = true end
        else
            primaries[tt] = true
        end
    end

    -- The hovered tooltip itself, when only its comparison frames fired.
    for owner in pairs(primaries) do
        if not inList[owner] and IsTooltipShown(owner) and IsAllowedTooltip(owner) then
            table.insert(list, 1, owner)
            inList[owner] = true
        end
    end

    for i = 1, 3 do
        local shop = _G["ShoppingTooltip" .. i]
        if shop and not inList[shop] and IsTooltipShown(shop) then
            local owner = GetTooltipOwner(shop)
            if owner and primaries[owner] and IsAllowedTooltip(shop) then
                list[#list + 1] = shop
                inList[shop] = true
            end
        end
    end

    -- Hovered item first, comparison frames after it in ShoppingTooltip order.
    local rank = {}
    for i, tt in ipairs(list) do
        local n = IsShoppingTooltip(tt) and (FrameName(tt) or "") or ""
        rank[tt] = { shopping = n ~= "", name = n, seq = i }
    end
    table.sort(list, function(a, b)
        local ra, rb = rank[a], rank[b]
        if ra.shopping ~= rb.shopping then return rb.shopping end
        if ra.shopping and ra.name ~= rb.name then return ra.name < rb.name end
        return ra.seq < rb.seq
    end)

    return list
end

local SpeakBatch

function SpeakBatch(order)
    if not UiTTSDB.enabled then return end
    if not order or #order == 0 then return end

    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if (now - lastGlobalSpeakAt) < minInterval then return end

    local list = ExpandComparisonGroup(order)

    local parts, keys, members, seen = {}, {}, {}, {}
    local fresh = false

    for _, tooltip in ipairs(list) do
        if tooltip
            and not (tooltip.IsForbidden and tooltip:IsForbidden())
            and IsTooltipShown(tooltip)
            and IsAllowedTooltip(tooltip)
        then
            local st = GetState(tooltip)
            local text = GetTooltipText(tooltip, st.lastData)
            if text and not seen[text] then
                seen[text] = true
                local ownerKey = GetOwnerKey(tooltip)
                -- Already spoken as part of the utterance that is still current:
                -- keep it out unless nothing new joined the batch.
                local carried = UiTTSDB.skipSameText
                    and st.lastText == text
                    and st.ownerKey == ownerKey
                    and st.batchSerial == batchSerial
                    and batchSerial > 0
                if not carried then fresh = true end

                local label = IsShoppingTooltip(tooltip) and ((L and L["Equipped:"]) or "Equipped:") or nil
                members[#members + 1] = {
                    tooltip = tooltip,
                    text = text,
                    ownerKey = ownerKey,
                    carried = carried,
                    spoken = label and (label .. " " .. text) or text,
                }
            end
        end
    end

    if not fresh then
        DebugTooltipLog("  -> dedup (batch unchanged)")
        return
    end

    -- A comparison frame that only shows up once the item it belongs to is
    -- already being read (Shift pressed mid-read): let the running utterance
    -- finish and then speak the new part, instead of cutting it off.
    local continuation = false
    for _, m in ipairs(members) do
        if m.carried then continuation = true break end
    end
    if continuation and IsSpeaking() then
        local snapshot = {}
        for i, tt in ipairs(list) do snapshot[i] = tt end
        RunAfterPlayback(function() SpeakBatch(snapshot) end)
        DebugTooltipLog("  -> queued behind current playback")
        return
    end

    for _, m in ipairs(members) do
        if not m.carried then
            parts[#parts + 1] = m.spoken
            keys[#keys + 1] = m.ownerKey
        end
    end
    if #parts == 0 then return end

    local merged = table.concat(parts, ". ")
    local batchKey = table.concat(keys, "|")

    if UiTTSDB.skipSameText and merged == lastGlobalSpokenText then
        DebugTooltipLog("  -> dedup (global match)")
        return
    end
    if UiTTSDB.skipSameText and batchKey == lastBatchKey and merged == lastBatchText then
        DebugTooltipLog("  -> dedup (same owners+text)")
        return
    end

    local lockFor = tonumber(UiTTSDB.lockSameOwnerFor) or 0
    if lockFor > 0 and batchKey == lastBatchKey and (now - lastBatchAt) < lockFor then
        DebugTooltipLog("  -> dedup (time lock)")
        return
    end

    DebugTooltipLog("  -> speaking", #parts, "tooltip(s):", merged:sub(1, 80))

    batchSerial = batchSerial + 1
    for _, m in ipairs(members) do
        local st = GetState(m.tooltip)
        st.ownerKey = m.ownerKey
        st.lastText = m.text
        st.lastSpokenAt = now
        st.batchSerial = batchSerial
    end

    lastGlobalSpeakAt = now
    lastGlobalSpokenText = merged
    lastBatchKey, lastBatchText, lastBatchAt = batchKey, merged, now

    Speak(merged)
end

local FlushPending, SchedulePendingFlush

function FlushPending()
    pendingScheduled = false
    local order = pendingOrder
    pendingSet, pendingOrder = {}, {}
    pendingDeadline, pendingStartedAt = 0, 0
    SpeakBatch(order)
end

function SchedulePendingFlush()
    if pendingScheduled then return end
    pendingScheduled = true

    local delay = pendingDeadline - GetTime()
    if delay < 0 then delay = 0 end

    C_Timer.After(delay, function()
        pendingScheduled = false
        -- A tooltip that joined after this timer was armed pushed the deadline
        -- out; wait for the rest of the group instead of speaking a partial set.
        if GetTime() + 0.005 < pendingDeadline then
            SchedulePendingFlush()
            return
        end
        FlushPending()
    end)
end

local function RequestSpeak(tooltip, data)
    if not UiTTSDB.enabled then return end
    if not tooltip or (tooltip.IsForbidden and tooltip:IsForbidden()) then return end
    if not IsTooltipShown(tooltip) then return end
    if not IsAllowedTooltip(tooltip) then return end

    -- Assigned unconditionally, nil included: keeping the previous call's data
    -- around would make the next item read from the structured lines of the
    -- last one. Comparison frames pulled in at flush time have no data and fall
    -- back to the named-globals builder, which is what they are built for.
    local st = GetState(tooltip)
    st.lastData = data

    local now = GetTime()
    if not pendingSet[tooltip] then
        pendingSet[tooltip] = true
        pendingOrder[#pendingOrder + 1] = tooltip
        if #pendingOrder == 1 then pendingStartedAt = now end
    end

    local delay = tonumber(UiTTSDB.debounceDelay) or 0
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    local remaining = minInterval - (now - lastGlobalSpeakAt)
    if remaining > delay then delay = remaining end
    if delay < 0 then delay = 0 end

    if not C_Timer or not C_Timer.After then
        FlushPending()
        return
    end

    -- Cap how far the batch window can slide, but never below what minInterval
    -- still owes -- flushing early there would only get the batch dropped.
    local deadline = now + delay
    local cap = pendingStartedAt + BATCH_MAX_WAIT
    if remaining > 0 and (now + remaining) > cap then cap = now + remaining end
    if deadline > cap then deadline = cap end
    if deadline > pendingDeadline then pendingDeadline = deadline end

    SchedulePendingFlush()
end

-- ========= Safe HookScript =========
local function TryHookScript(frame, scriptName, func)
    if not frame or not frame.HookScript then return end
    if frame.HasScript then
        -- pcall: Mixin Lua tables expose HasScript as a C-function reference
        -- that raises "bad self" when called on the table itself.
        local ok, has = pcall(frame.HasScript, frame, scriptName)
        if ok and not has then return end
        -- If pcall failed (Mixin table), fall through; HookScript is also pcall'd.
    end
    pcall(function() frame:HookScript(scriptName, func) end)
end

-- ========= Generic frame-tree text collector =========
-- Recursively collects visible FontString text from an arbitrary frame tree.
-- Returns a list of { text, y } entries (unsorted); caller sorts as needed.

local SKIP_OBJECT_TYPES = {
    Model = true, PlayerModel = true, CinematicModel = true,
    DressUpModel = true, TabardModel = true,
}

local DECORATIVE_SUFFIXES = {
    "Background", "Border", "Shadow", "Glow", "Shine", "Flash",
    "Overlay", "Backdrop", "BG", "Bg", "FX", "Fx",
}

-- Every C method on a *protected* object raises "Attempt to access forbidden
-- object from code tainted by an AddOn" when called from addon code -- and
-- IsForbidden() is not a reliable pre-check, because a frame can be reachable
-- and still refuse the call (Blizzard_CatalogShop's ScrollBoxListView buttons
-- do exactly that). Every C call made while walking a foreign frame tree must
-- therefore be pcall'd; an error means "unknown", not "crash the read".
local function SafeObjectType(obj)
    if not obj or not obj.GetObjectType then return nil end
    local ok, ot = pcall(obj.GetObjectType, obj)
    if not ok then return nil end
    return ot
end

local function IsDecorativeChildFrame(frame)
    local ot = SafeObjectType(frame)
    if ot and SKIP_OBJECT_TYPES[ot] then return true end
    local name = FrameName(frame)
    if name then
        local tail = name:match("[^%.]+$") or name
        for _, suf in ipairs(DECORATIVE_SUFFIXES) do
            if tail:find(suf, 1, true) then return true end
        end
    end
    return false
end

function CollectFrameText(frame, lines, depth, seen)
    lines = lines or {}
    depth = depth or 0
    seen  = seen  or {}

    if not frame or depth > 8 then return lines end
    if seen[frame] then return lines end
    seen[frame] = true
    if frame.IsForbidden then
        local okF, forbidden = pcall(frame.IsForbidden, frame)
        if okF and forbidden then return lines end
    end
    if depth > 0 and frame.IsVisible then
        local okV, visible = pcall(frame.IsVisible, frame)
        if okV and not visible then return lines end
    end

    -- Collect up to a generous hard cap (NOT maxLines): callers sort the full
    -- set by Y and only then trim to maxLines, so breaking early here in
    -- tree-traversal order would drop top-of-screen lines that appear late in
    -- the frame tree.
    local COLLECT_HARD_CAP = 80

    if frame.GetRegions then
        local ok, regions = pcall(function() return { frame:GetRegions() } end)
        if ok and regions then
            for _, r in ipairs(regions) do
                if #lines >= COLLECT_HARD_CAP then break end
                if r and SafeObjectType(r) == "FontString" and r.GetText then
                    local okT, raw = pcall(r.GetText, r)
                    local t = okT and CleanText(raw) or nil
                    if t then
                        lines[#lines + 1] = { text = t, y = RegionY(r) }
                    end
                end
            end
        end
    end

    if frame.GetChildren then
        local ok, kids = pcall(function() return { frame:GetChildren() } end)
        if ok and kids then
            for _, child in ipairs(kids) do
                if child and not IsDecorativeChildFrame(child) then
                    CollectFrameText(child, lines, depth + 1, seen)
                end
            end
        end
    end

    return lines
end

-- ========= Shared text/speak helpers (consumed by UIReader / Chat) =========

-- Collects visible FontStrings from a frame tree, sorts them top-to-bottom by
-- Y, deduplicates, trims to maxLines and joins with ". ". This is the single
-- implementation every UI reader shares (previously copy-pasted ~7 times).
local function BuildSortedText(frame, maxLinesOverride)
    if not frame or not CollectFrameText then return nil end
    local lines = CollectFrameText(frame, {}, 0, {})
    if not lines or #lines == 0 then return nil end
    SortLinesByY(lines)

    local seen, out = {}, {}
    local maxLines = maxLinesOverride or (UiTTSDB and UiTTSDB.maxLines) or 12
    for _, l in ipairs(lines) do
        if #out >= maxLines then break end
        if l.text and not seen[l.text] then
            seen[l.text] = true
            out[#out + 1] = l.text
        end
    end
    if #out == 0 then return nil end
    return table.concat(out, ". ")
end

-- Shared isolated-dedup speak path. `state` is a per-reader table {txt, at};
-- keeping it caller-owned (rather than a closure) preserves the ability for
-- readers to reset it on hide/show and for the Shop reader to inspect the last
-- spoken text. Replaces the near-identical SpeakX bodies across readers.
local function IsolatedSpeak(state, text, dedupWindow)
    if not (UiTTSDB and UiTTSDB.enabled) then return end
    if not text then return end
    local now = GetTime()
    if UiTTSDB.skipSameText and text == state.txt
        and (now - (state.at or 0)) < (dedupWindow or 2.0) then
        return
    end
    if (now - (state.at or 0)) < (tonumber(UiTTSDB.minInterval) or 0) then return end
    state.txt = text
    state.at  = now
    Speak(text)
end

-- ========= Shared namespace =========
-- UiTTS_NS may already contain MakeChannel (populated by UiTTS_Channels.lua,
-- which loads before this file). Merge instead of overwrite.
UiTTS_NS = UiTTS_NS or {}
UiTTS_NS.ClientInfo       = client
UiTTS_NS.IsAddonAvailable = IsAddonAvailable
UiTTS_NS.HasTradingPost   = hasTradingPost
UiTTS_NS.IsSecretValue    = IsSecretValue
UiTTS_NS.CanAccessTable   = CanAccessTable
UiTTS_NS.CleanText        = CleanText
UiTTS_NS.Speak            = Speak
UiTTS_NS.SpeakForced      = SpeakForced
UiTTS_NS.StopSpeaking     = StopSpeaking
UiTTS_NS.FrameName        = FrameName
UiTTS_NS.TryHookScript    = TryHookScript
UiTTS_NS.CollectFrameText = CollectFrameText
UiTTS_NS.BuildSortedText  = BuildSortedText
UiTTS_NS.SafeNumber       = SafeNumber
UiTTS_NS.RegionY          = RegionY
UiTTS_NS.SortLinesByY     = SortLinesByY
UiTTS_NS.SafeObjectType   = SafeObjectType
UiTTS_NS.IsolatedSpeak    = IsolatedSpeak

-- ========= Hooks =========
local function TooltipHandler(tooltip, data)
    RequestSpeak(tooltip, data)
end

-- LibQTip tooltips override :HookScript to route straight into
-- geterrorhandler(), bypassing pcall — every attempt surfaces
-- ":HookScript is not allowed on LibQTip tooltips" in the Blizzard error log.
local function IsLibQTipTooltip(tooltip)
    if not tooltip then return false end
    if type(tooltip.labelProvider) ~= "table" then return false end
    if tooltip.layoutType ~= "TooltipDefaultLayout" then return false end
    return true
end

local function HookTooltipFrame(tooltip)
    if not tooltip or tooltip.__UiTTSHooked then return end
    if IsLibQTipTooltip(tooltip) then
        tooltip.__UiTTSHooked = true
        return
    end
    tooltip.__UiTTSHooked = true

    TryHookScript(tooltip, "OnShow", function(self) RequestSpeak(self, nil) end)
    TryHookScript(tooltip, "OnHide", function(self) tooltipState[self] = nil end)

    TryHookScript(tooltip, "OnTooltipSetItem",  function(self) RequestSpeak(self, nil) end)
    TryHookScript(tooltip, "OnTooltipSetSpell", function(self) RequestSpeak(self, nil) end)
    TryHookScript(tooltip, "OnTooltipSetUnit",  function(self) RequestSpeak(self, nil) end)

    -- OnTooltipCleared fires when ClearLines() is called, which happens every time
    -- a tooltip owner changes — even when the frame stays visible (e.g. moving
    -- between Profession Specialization nodes). Without this hook, OnShow never
    -- re-fires for the second and later nodes and the new text is never spoken.
    TryHookScript(tooltip, "OnTooltipCleared", function(self)
        DebugTooltipLog("OnTooltipCleared:", FrameName(self) or "?")
        local st = tooltipState[self]
        if st then st.lastText = nil end
        RequestSpeak(self, nil)
    end)
end

local function TryHookKnownTooltips()
    HookTooltipFrame(GameTooltip)

    if _G.SpellBookTooltip then HookTooltipFrame(_G.SpellBookTooltip) end
    if _G.SpellBookFrame and _G.SpellBookFrame.tooltip then HookTooltipFrame(_G.SpellBookFrame.tooltip) end

    if _G.ClassTalentFrame and _G.ClassTalentFrame.Tooltip then HookTooltipFrame(_G.ClassTalentFrame.Tooltip) end
    if _G.ClassTalentTooltip then HookTooltipFrame(_G.ClassTalentTooltip) end
    if _G.TalentFrameTooltip then HookTooltipFrame(_G.TalentFrameTooltip) end
    if _G.TalentsTooltip then HookTooltipFrame(_G.TalentsTooltip) end

    if _G.TradingPostTooltip then HookTooltipFrame(_G.TradingPostTooltip) end
    if _G.PerksProgramTooltip then HookTooltipFrame(_G.PerksProgramTooltip) end
    if _G.PerksProgramFrame and _G.PerksProgramFrame.Tooltip then HookTooltipFrame(_G.PerksProgramFrame.Tooltip) end

    -- Profession specialization nodes use GameTooltip directly; the GameTooltip
    -- hook + OnTooltipCleared covers them. These catch any dedicated tooltip
    -- frames the Professions UI might add.
    if _G.ProfessionsFrame and _G.ProfessionsFrame.Tooltip then HookTooltipFrame(_G.ProfessionsFrame.Tooltip) end
    if _G.ProfessionsSpecTooltip then HookTooltipFrame(_G.ProfessionsSpecTooltip) end
    if _G.ProfessionsBookTooltip then HookTooltipFrame(_G.ProfessionsBookTooltip) end
    if _G.ProfessionsCraftingTooltip then HookTooltipFrame(_G.ProfessionsCraftingTooltip) end

    if _G.QuestInfoItemTooltip then HookTooltipFrame(_G.QuestInfoItemTooltip) end
    if _G.QuestInfoTooltip then HookTooltipFrame(_G.QuestInfoTooltip) end
    if _G.EmbeddedItemTooltip then HookTooltipFrame(_G.EmbeddedItemTooltip) end

    if _G.ItemRefTooltip then HookTooltipFrame(_G.ItemRefTooltip) end
    if _G.ShoppingTooltip1 then HookTooltipFrame(_G.ShoppingTooltip1) end
    if _G.ShoppingTooltip2 then HookTooltipFrame(_G.ShoppingTooltip2) end
end

-- Ticker runs at a fixed 0.5s base rate; the function throttles internally
-- by UiTTSDB.scanInterval. Backoff (up to 4 levels = 16x) reduces CPU cost
-- once the frame population stabilises, and resets when new tooltips appear.
local lastScanTime = 0
local scanBackoffLevel = 0
local scanCursor = nil          -- resume point of an interrupted walk (nil = start over)
local scanFound = 0             -- tooltips hooked so far by the walk in progress
local scanResumeQueued = false

-- A full EnumerateFrames walk touches every frame in the UI — on a heavily
-- addon-loaded client (bag addons alone create thousands of item buttons and
-- cooldown frames) a single uninterrupted pass exceeds WoW's per-script time
-- limit and raises "script ran too long". The walk is therefore chunked the
-- same way the DialogueUI option scan is: run for at most SCAN_BUDGET_MS, park
-- the EnumerateFrames cursor and resume shortly after. Frames are never
-- destroyed in WoW, so a parked cursor stays valid.
local SCAN_BUDGET_MS    = 4.0
local SCAN_CLOCK_EVERY  = 250    -- frames between debugprofilestop() reads
local SCAN_RESUME_DELAY = 0.05   -- s before continuing an interrupted walk

-- Tests are ordered cheapest-first, because this runs for every unhooked frame
-- in the UI: plain table lookups, then one GetObjectType C call, then GetName,
-- and only last the pcall-guarded strata read.
local function LooksLikeDynamicTooltip(f)
    -- Custom Mixin tooltips (e.g. DialogueUI's SharedTooltip) implement
    -- SetOwner/AddLine/ClearLines but never define GetOwner, so GetOwner is
    -- deliberately not required here. Table lookups only — no C call.
    if f.SetOwner and f.AddLine and f.ClearLines then return true end

    if f.GetObjectType and f:GetObjectType() == "GameTooltip" then return true end

    if f.GetName then
        local name = f:GetName()
        if type(name) == "string" and name:find("Tooltip") then return true end
    end

    -- Catch unnamed custom tooltips (DialogueUI etc.) by frame strata.
    -- Protected frames return a tainted "secret string" from GetFrameStrata;
    -- comparing it raises a Lua error, so skip when IsSecretValue is true.
    if f.GetFrameStrata and f.HookScript then
        local okStrata, strata = pcall(f.GetFrameStrata, f)
        if okStrata and not IsSecretValue(strata) and strata == "TOOLTIP" then
            return true
        end
    end

    return false
end

local ScanAndHookDynamicTooltips   -- forward declaration (resume closure)

function ScanAndHookDynamicTooltips()
    if not UiTTSDB.scanDynamicTooltips then return end
    if type(EnumerateFrames) ~= "function" then return end
    if InCombatLockdown and InCombatLockdown() then return end

    -- The interval gate only applies between walks; a partial walk always
    -- resumes, otherwise a chunked pass could never finish.
    if scanCursor == nil then
        local baseInterval = tonumber(UiTTSDB.scanInterval) or 1.0
        local effectiveInterval = scanBackoffLevel > 0
            and math.min(baseInterval * (2 ^ scanBackoffLevel), 30.0)
            or baseInterval

        local now = GetTime()
        if (now - lastScanTime) < effectiveInterval then return end
        lastScanTime = now
        scanFound = 0
    end

    local f = scanCursor

    local deadline = nil
    if type(debugprofilestop) == "function" then
        deadline = debugprofilestop() + SCAN_BUDGET_MS
    end

    local sinceClock = 0
    local exhausted = false
    while true do
        f = EnumerateFrames(f)
        if not f then
            exhausted = true
            break
        end

        if not f.__UiTTSHooked and LooksLikeDynamicTooltip(f) then
            HookTooltipFrame(f)
            scanFound = scanFound + 1
        end

        if deadline then
            sinceClock = sinceClock + 1
            if sinceClock >= SCAN_CLOCK_EVERY then
                sinceClock = 0
                if debugprofilestop() >= deadline then break end
            end
        end
    end

    if not exhausted then
        -- Out of time budget: park the cursor and pick up where we left off.
        scanCursor = f
        if C_Timer and C_Timer.After and not scanResumeQueued then
            scanResumeQueued = true
            C_Timer.After(SCAN_RESUME_DELAY, function()
                scanResumeQueued = false
                ScanAndHookDynamicTooltips()
            end)
        end
        return
    end

    scanCursor = nil

    if scanFound == 0 then
        scanBackoffLevel = math.min(scanBackoffLevel + 1, 4)
    else
        scanBackoffLevel = 0
    end
    scanFound = 0
end

-- ========= User actions (shared by slash commands and keybindings) =========
local function SetEnabled(on)
    UiTTSDB.enabled = on and true or false
    if UiTTSDB.enabled then
        print(L["UiTTS: enabled."])
    else
        StopSpeaking()
        tooltipState = {}
        lastGlobalSpokenText = nil
        print(L["UiTTS: disabled."])
    end
end

local function ToggleEnabled()
    SetEnabled(not UiTTSDB.enabled)
end

-- Re-speaks the last thing any reader spoke this session.
local function RepeatLast()
    if lastSpokenGlobalText and lastSpokenGlobalText ~= "" then
        SpeakForced(lastSpokenGlobalText)
    end
end

-- Reads whatever GameTooltip is currently showing, bypassing the per-category
-- gates so the user can hear a tooltip on demand even when auto-reading is off.
local function ReadCurrentTooltip()
    local tt = GameTooltip
    if not tt then return end
    if tt.IsShown and not tt:IsShown() then return end
    local text = GetTooltipText(tt, nil)
    if text then SpeakForced(text) end
end

local function OpenCategory(id)
    if Settings and Settings.OpenToCategory and type(id) == "number" then
        Settings.OpenToCategory(id)
        return true
    end
    return false
end

local function OpenConfig()
    if OpenCategory(_G.UiTTS_OptionsCategoryID) then return end
    if InterfaceOptionsFrame_OpenToCategory and _G.UiTTS_OptionsPanel then
        -- Called twice as a legacy WoW workaround to scroll the panel into view
        InterfaceOptionsFrame_OpenToCategory(_G.UiTTS_OptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(_G.UiTTS_OptionsPanel)
    else
        print(L["UiTTS: Open Settings -> AddOns -> UiTTS."])
    end
end

local function OpenGuide()
    if OpenCategory(_G.UiTTS_GuideCategoryID) then return end
    OpenConfig()
end

-- A reusable, movable window with a selectable multiline edit box, so text
-- (e.g. the diagnostic) can be copied out with Ctrl+A / Ctrl+C.
local copyFrame
local function ShowCopyWindow(titleText, bodyText)
    if not copyFrame then
        local fr = CreateFrame("Frame", "UiTTSCopyFrame", UIParent, "BackdropTemplate")
        fr:SetSize(560, 380)
        fr:SetPoint("CENTER")
        fr:SetFrameStrata("DIALOG")
        fr:SetMovable(true); fr:EnableMouse(true); fr:RegisterForDrag("LeftButton")
        fr:SetScript("OnDragStart", fr.StartMoving)
        fr:SetScript("OnDragStop", fr.StopMovingOrSizing)
        fr:SetClampedToScreen(true)
        if fr.SetBackdrop then
            fr:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, tileSize = 32, edgeSize = 32,
                insets = { left = 8, right = 8, top = 8, bottom = 8 },
            })
        end

        local titleFS = fr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFS:SetPoint("TOP", 0, -14)
        fr.titleFS = titleFS

        local hint = fr:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("TOP", titleFS, "BOTTOM", 0, -4)
        hint:SetText(L["Press Ctrl+A then Ctrl+C to copy."])

        local sf = CreateFrame("ScrollFrame", "UiTTSCopyScroll", fr, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT", 16, -54)
        sf:SetPoint("BOTTOMRIGHT", -34, 44)

        local eb = CreateFrame("EditBox", nil, sf)
        eb:SetMultiLine(true)
        eb:SetFontObject(ChatFontNormal)
        eb:SetWidth(500)
        eb:SetAutoFocus(false)
        eb:EnableMouse(true)
        eb:SetScript("OnEscapePressed", function() fr:Hide() end)
        sf:SetScrollChild(eb)
        fr.editBox = eb

        local close = CreateFrame("Button", nil, fr, "UIPanelButtonTemplate")
        close:SetSize(100, 22)
        close:SetPoint("BOTTOM", 0, 14)
        close:SetText(L["Close"])
        close:SetScript("OnClick", function() fr:Hide() end)

        copyFrame = fr
    end
    copyFrame.titleFS:SetText(titleText or "UiTTS")
    copyFrame.editBox:SetText(bodyText or "")
    copyFrame.editBox:HighlightText()
    copyFrame.editBox:SetFocus()
    copyFrame:Show()
end
UiTTS_NS.ShowCopyWindow = ShowCopyWindow

-- Builds a human-readable diagnostic dump, including every installed TTS voice
-- and its ID, so a "nothing is read" report can be diagnosed at a glance.
local function BuildDiagnosticText()
    local hasSpeak = (C_VoiceChat and C_VoiceChat.SpeakText) and true or false
    local lines = {}
    local function add(s) lines[#lines + 1] = s end

    add("UiTTS diagnostic")
    add("client = " .. (client.isForever and "WoW Forever Beta" or "WoW")
        .. " " .. tostring(client.version))
    add("build = " .. tostring(client.build))
    add("interface = " .. tostring(client.interface))
    add("enabled = " .. tostring(UiTTSDB.enabled))
    add("SpeakText available = " .. tostring(hasSpeak))
    add("SpeakText signature = voiceID, text, rate, volume, overlap")
    add("TooltipDataProcessor available = " .. tostring(TooltipDataProcessor ~= nil))
    add("Settings available = " .. tostring(Settings ~= nil))
    add("Trading Post available = " .. tostring(hasTradingPost))
    add("selected voiceID = " .. tostring(GetSelectedVoiceID()))
    add("rate = " .. tostring(GetChatTTSRate()))
    add("volume = " .. tostring(GetChatTTSVolume()))
    add("useAlternateVoice = " .. tostring(UiTTSDB.useAlternateVoice))
    add("useCustomTTS = " .. tostring(UiTTSDB.useCustomTTS))
    add("voiceID override = " .. tostring(UiTTSDB.voiceID))
    add("")
    add("installed voices:")
    if C_VoiceChat and C_VoiceChat.GetTtsVoices then
        local voices = C_VoiceChat.GetTtsVoices()
        if type(voices) == "table" and #voices > 0 then
            for _, v in ipairs(voices) do
                add(string.format("  [%s] %s", tostring(v.voiceID), tostring(v.name)))
            end
        else
            add("  (none installed — add a voice in your OS speech settings)")
        end
    else
        add("  (C_VoiceChat.GetTtsVoices unavailable)")
    end
    return table.concat(lines, "\n")
end

-- Opens the diagnostic in a copyable window and speaks a test phrase (/uitts test).
local function RunDiagnostic()
    ShowCopyWindow("UiTTS", BuildDiagnosticText())
    SpeakForced(L["UiTTS test. One, two, three."])
end

-- Expose actions for keybindings (UiTTS_NS) and the guide/options modules.
UiTTS_NS.ToggleEnabled     = ToggleEnabled
UiTTS_NS.SetEnabled        = SetEnabled
UiTTS_NS.RepeatLast        = RepeatLast
UiTTS_NS.ReadCurrentTooltip = ReadCurrentTooltip
UiTTS_NS.OpenConfig        = OpenConfig
UiTTS_NS.OpenGuide         = OpenGuide

-- Global wrappers referenced by Bindings.xml (binding actions run in the global
-- environment).
function UiTTS_Binding_Toggle()      ToggleEnabled() end
function UiTTS_Binding_Stop()        StopSpeaking() end
function UiTTS_Binding_Repeat()      RepeatLast() end
function UiTTS_Binding_ReadTooltip() ReadCurrentTooltip() end

-- Keybinding display names (Key Bindings UI reads these globals).
_G.BINDING_HEADER_UITTS            = "UiTTS"
_G.BINDING_NAME_UITTS_TOGGLE       = L["Toggle UiTTS on/off"]
_G.BINDING_NAME_UITTS_STOP         = L["Stop speaking"]
_G.BINDING_NAME_UITTS_REPEAT       = L["Repeat last spoken text"]
_G.BINDING_NAME_UITTS_READ_TOOLTIP = L["Read current tooltip"]

-- ========= Slash =========
SLASH_UITTS1 = "/uitts"
SlashCmdList["UITTS"] = function(msg)
    msg = (msg or ""):lower()

    if msg == "on" then
        SetEnabled(true)
    elseif msg == "off" then
        SetEnabled(false)
    elseif msg == "toggle" then
        ToggleEnabled()
    elseif msg == "stop" then
        StopSpeaking()
    elseif msg == "repeat" then
        RepeatLast()
    elseif msg == "test" then
        RunDiagnostic()
    elseif msg == "config" or msg == "tts" then
        OpenConfig()
    elseif msg == "guide" then
        OpenGuide()
    else
        print("UiTTS: /uitts on | off | toggle | stop | repeat | test | config | guide")
    end
end

SLASH_ABLECRAFT1 = "/ablecraft"
SLASH_ABLECRAFT2 = "/ac"
SlashCmdList["ABLECRAFT"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "" then
        if OpenCategory(_G.AbleCraft_OptionsCategoryID) then return end
        OpenConfig()
    else
        SlashCmdList["UITTS"](msg)
    end
end

-- ========= Init =========
local scanTicker
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, addonName)
    if event == "PLAYER_LOGIN" then
        ApplyDefaults()

        if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
            TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, TooltipHandler)
        end

        TryHookKnownTooltips()
        ScanAndHookDynamicTooltips()

        -- Fixed ticker runs at 0.5s so scanInterval changes take effect immediately.
        if C_Timer and C_Timer.NewTicker and not scanTicker then
            scanTicker = C_Timer.NewTicker(0.5, ScanAndHookDynamicTooltips)
        end

        if C_Timer and C_Timer.After then
            C_Timer.After(1.0, TryHookKnownTooltips)
            C_Timer.After(2.0, ScanAndHookDynamicTooltips)
            C_Timer.After(3.0, TryHookKnownTooltips)
        end

        print(L["AbleCraft loaded. Use /ablecraft or /uitts config to open options."])
        return
    end

    if event == "ADDON_LOADED" then
        if addonName == "DialogueUI"
            or addonName == "Blizzard_PlayerSpells"
            or addonName == "Blizzard_SpellBook"
            or addonName == "Blizzard_ClassTalentUI"
            or addonName == "Blizzard_TradingPostUI"
            or addonName == "Blizzard_PerksProgram"
            or addonName == "Blizzard_PerksProgramUI"
            or addonName == "Blizzard_QuestUI"
            or addonName == "Blizzard_QuestChoice"
            or addonName == "Blizzard_ItemRefUI"
            or addonName == "Blizzard_Professions"
            or addonName == "Blizzard_ProfessionsBook"
            or addonName == "Blizzard_ProfessionsCrafting"
            or addonName == "Blizzard_UIPanels_Game"
            or addonName == "Blizzard_GameTooltip"
        then
            scanBackoffLevel = 0
            lastScanTime = 0
            scanCursor = nil       -- restart the chunked walk from the top
            TryHookKnownTooltips()
            ScanAndHookDynamicTooltips()
        end
    end
end)
