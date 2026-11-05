-- UiTTS_Chat.lua (WoW Forever Beta 1.60.x; modern Mainline UI API)
--
-- Reads chat messages and a couple of low-noise state events aloud:
--   • Whispers (player and Battle.net), party, say, guild, yell — each gated by
--     its own toggle. Only whispers are on by default; the noisier channels
--     stay silent until the user opts in.
--   • Loot messages ("You receive loot: ...").
--   • Target changes (name + level).
--
-- All speech routes through UiTTS_NS.Speak, so it honours the master enable
-- switch, the selected voice, custom rate/volume and interrupt behaviour.

local NS = UiTTS_NS
local L  = UiTTS_L

local CleanText = (NS and NS.CleanText) or function(s)
    if type(s) ~= "string" or s == "" then return nil end
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1")
    s = s:gsub("\n+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s ~= "" and s or nil
end

local Speak = (NS and NS.Speak) or function(text)
    if not (UiTTSDB and UiTTSDB.enabled) or not text then return end
    if C_VoiceChat and C_VoiceChat.SpeakText then
        local vt = UiTTSDB.useAlternateVoice and Enum.TtsVoiceType.Alternate or Enum.TtsVoiceType.Standard
        local vid = C_TTSSettings and C_TTSSettings.GetVoiceOptionID and C_TTSSettings.GetVoiceOptionID(vt) or 0
        -- Forever / Retail: (voiceID, text, rate, volume, allowOverlappedSpeech).
        C_VoiceChat.SpeakText(vid, text, 0, 100, false)
    end
end

local function Fmt(key, fallback, ...)
    local pattern = (L and L[key]) or fallback
    return string.format(pattern, ...)
end

-- Strip a trailing "-Realm" from a sender name so the TTS reads just the name.
local function ShortName(name)
    if type(name) ~= "string" then return name end
    return name:match("^([^-]+)") or name
end

-- ========= Chat channels =========
-- Each entry: event -> { gate = DB key, format key, fallback pattern }.
-- The message text is arg1 and the sender is arg2 for all CHAT_MSG_* events.
local CHAT_CHANNELS = {
    CHAT_MSG_WHISPER        = { gate = "readWhispers", key = "Whisper from %s: %s", fallback = "Whisper from %s: %s" },
    CHAT_MSG_BN_WHISPER     = { gate = "readWhispers", key = "Whisper from %s: %s", fallback = "Whisper from %s: %s" },
    CHAT_MSG_PARTY          = { gate = "readParty",    key = "Party, %s: %s",       fallback = "Party, %s: %s" },
    CHAT_MSG_PARTY_LEADER   = { gate = "readParty",    key = "Party, %s: %s",       fallback = "Party, %s: %s" },
    CHAT_MSG_SAY            = { gate = "readSay",      key = "%s says: %s",         fallback = "%s says: %s" },
    CHAT_MSG_GUILD          = { gate = "readGuild",    key = "Guild, %s: %s",       fallback = "Guild, %s: %s" },
    CHAT_MSG_YELL           = { gate = "readYell",     key = "%s yells: %s",        fallback = "%s yells: %s" },
}

local function HandleChat(event, msg, author)
    local cfg = CHAT_CHANNELS[event]
    if not cfg then return end
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB[cfg.gate]) then return end

    local text = CleanText(msg)
    if not text then return end
    local who = ShortName(CleanText(author) or "")

    if who and who ~= "" then
        Speak(Fmt(cfg.key, cfg.fallback, who, text))
    else
        Speak(text)
    end
end

-- ========= Loot =========
local function HandleLoot(msg)
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readLoot) then return end
    local text = CleanText(msg)
    if text then Speak(text) end
end

-- ========= Target change =========
local lastTargetName = nil

local function HandleTargetChange()
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readTargetChange) then return end
    if not (UnitExists and UnitExists("target")) then
        lastTargetName = nil
        return
    end
    local name = UnitName and UnitName("target")
    name = CleanText(name)
    if not name then return end
    if name == lastTargetName then return end   -- ignore re-targeting the same unit
    lastTargetName = name

    local level = UnitLevel and UnitLevel("target")
    if NS and NS.SafeNumber then level = NS.SafeNumber(level) end
    if level and level > 0 then
        Speak(Fmt("Target: %s, level %d", "Target: %s, level %d", name, level))
    else
        Speak(Fmt("Target: %s", "Target: %s", name))
    end
end

-- ========= Init =========
local chatFrame = CreateFrame("Frame")
for event in pairs(CHAT_CHANNELS) do
    chatFrame:RegisterEvent(event)
end
chatFrame:RegisterEvent("CHAT_MSG_LOOT")
chatFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

chatFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "CHAT_MSG_LOOT" then
        HandleLoot(arg1)
    elseif event == "PLAYER_TARGET_CHANGED" then
        HandleTargetChange()
    else
        HandleChat(event, arg1, arg2)
    end
end)
