-- UiTTS_UIReader.lua (WoW Forever Beta 1.60.x; modern Mainline UI API)
--
-- Reads visible button labels from the Game Menu (ESC) and Settings panel,
-- and reads SettingsTooltip text when hovering options in the Settings UI.
--
-- Shared utilities are consumed from UiTTS_NS, which UiTTS.lua populates
-- before this file loads (enforced by .toc load order).

local NS = UiTTS_NS  -- set by UiTTS.lua at file-scope; safe to capture now
local L  = UiTTS_L   -- i18n string table populated by Locales/*.lua

-- ========= Inline fallbacks (guard against unexpected load-order changes) =========

local CleanText = NS and NS.CleanText or function(s)
    if type(s) ~= "string" or s == "" then return nil end
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1")
    s = s:gsub("\n+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s ~= "" and s or nil
end

local StopSpeaking = NS and NS.StopSpeaking or function()
    if C_VoiceChat and C_VoiceChat.StopSpeakingText then
        C_VoiceChat.StopSpeakingText()
    end
end

local Speak = NS and NS.Speak or function(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text or text == "" then return end
    if UiTTSDB.interruptOnNew and C_VoiceChat and C_VoiceChat.StopSpeakingText then
        C_VoiceChat.StopSpeakingText()
    end
    if C_VoiceChat and C_VoiceChat.SpeakText then
        local vt = UiTTSDB.useAlternateVoice and Enum.TtsVoiceType.Alternate or Enum.TtsVoiceType.Standard
        local vid = C_TTSSettings and C_TTSSettings.GetVoiceOptionID and C_TTSSettings.GetVoiceOptionID(vt) or 0
        local rate = C_TTSSettings and C_TTSSettings.GetSpeechRate and C_TTSSettings.GetSpeechRate() or 0
        local vol  = C_TTSSettings and C_TTSSettings.GetSpeechVolume and C_TTSSettings.GetSpeechVolume() or 100
        -- Forever / Retail: (voiceID, text, rate, volume, allowOverlappedSpeech).
        C_VoiceChat.SpeakText(vid, text, rate, vol, false)
    end
end

local FrameName = NS and NS.FrameName or function(f)
    if not f then return nil end
    if f.GetName then
        local n = f:GetName()
        if n and n ~= "" then return n end
    end
    return nil
end

local TryHookScript = NS and NS.TryHookScript or function(frame, scriptName, func)
    if not frame or not frame.HookScript then return end
    if frame.HasScript then
        local ok, has = pcall(frame.HasScript, frame, scriptName)
        if ok and not has then return end
    end
    pcall(function() frame:HookScript(scriptName, func) end)
end

-- CollectFrameText is defined in UiTTS.lua and exposed via UiTTS_NS.
-- If the load order ever breaks the reference, fall back to nil so the
-- toast reader degrades gracefully rather than erroring.
local CollectFrameText = NS and NS.CollectFrameText

-- Secret-safe Y helpers from UiTTS.lua: `sort` orders {text,y} lines
-- top-to-bottom without ever comparing a secret number (GetPoint on protected
-- regions returns those, and comparing them errors out of the sort), `of`
-- reads a region's Y as a plain number or nil. Both live in one table because
-- this file is near Lua's 200-locals-per-chunk limit.
local yutil = {
    sort = (NS and NS.SortLinesByY) or function(lines) return lines end,
    of   = (NS and NS.RegionY) or function() return nil end,
}

-- Shared "collect visible FontStrings -> sort top-to-bottom -> dedup -> trim ->
-- join" helper, and the shared isolated-dedup speak path. Both live in UiTTS.lua
-- (UiTTS_NS); inline fallbacks keep this file working if load order ever breaks.
local BuildSortedText = (NS and NS.BuildSortedText) or function(frame)
    if not frame or not CollectFrameText then return nil end
    local lines = CollectFrameText(frame, {}, 0, {})
    if not lines or #lines == 0 then return nil end
    yutil.sort(lines)
    local seen, out = {}, {}
    local maxLines = (UiTTSDB and UiTTSDB.maxLines) or 12
    for _, l in ipairs(lines) do
        if #out >= maxLines then break end
        if l.text and not seen[l.text] then seen[l.text] = true; out[#out + 1] = l.text end
    end
    return #out > 0 and table.concat(out, ". ") or nil
end

-- ========= Debug logging =========

local function DebugLog(...)
    if UiTTSDB and UiTTSDB.debugUIReader then
        print("|cff88aaff[UiTTS UIReader]|r", ...)
    end
end

-- ========= Button / control text extraction =========
--
-- GetButtonLabel tries multiple strategies in order, returning the first
-- non-empty cleaned string found, or nil if nothing is visible.

local function GetButtonLabel(frame)
    if not frame then return nil end
    if frame.IsForbidden and frame:IsForbidden() then return nil end

    -- 1. Button:GetText() — standard for Button / CheckButton frames
    if frame.GetText then
        local ok, t = pcall(frame.GetText, frame)
        if ok and type(t) == "string" then
            t = CleanText(t)
            if t then return t end
        end
    end

    -- 2. Named child fields used by common Blizzard templates
    local fieldNames = { "Text", "text", "Label", "label", "ButtonText", "Title", "Name" }
    for _, fname in ipairs(fieldNames) do
        local child = frame[fname]
        if child and type(child) == "table" and child.GetText then
            local t = CleanText(child:GetText())
            if t then return t end
        end
    end

    -- 3. Named globals derived from the frame's own name (e.g. "GameMenuButtonContinueText")
    local gname = FrameName(frame)
    if gname then
        for _, suffix in ipairs({ "Text", "Label", "Title" }) do
            local named = _G[gname .. suffix]
            if named and named.GetText then
                local t = CleanText(named:GetText())
                if t then return t end
            end
        end
    end

    -- 4. FontString regions (covers text attached to the frame itself, not children)
    if frame.GetRegions then
        local ok2, regions = pcall(function() return { frame:GetRegions() } end)
        if ok2 and regions then
            -- Collect all non-empty FontStrings sorted top-to-bottom by Y position
            local candidates = {}
            for _, r in ipairs(regions) do
                if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.GetText then
                    local t = CleanText(r:GetText())
                    if t then
                        candidates[#candidates + 1] = { text = t, y = yutil.of(r) }
                    end
                end
            end
            if #candidates > 0 then
                yutil.sort(candidates)
                return candidates[1].text
            end
        end
    end

    -- 5. FontString direct children (less common but used in some composite widgets)
    if frame.GetChildren then
        local ok3, kids = pcall(function() return { frame:GetChildren() } end)
        if ok3 and kids then
            for _, child in ipairs(kids) do
                if child and child.GetObjectType and child:GetObjectType() == "FontString" and child.GetText then
                    local t = CleanText(child:GetText())
                    if t then return t end
                end
            end
        end
    end

    return nil
end

-- ========= UIReader speak path =========
-- Maintains its own lightweight dedup so button-label reads don't fight the
-- main tooltip dedup table.  Reuses UiTTSDB.minInterval and skipSameText.

local lastUIReaderText = nil
local lastUIReaderAt   = 0

local function SpeakUILabel(text, context)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end

    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0

    if UiTTSDB.skipSameText and text == lastUIReaderText
        and (now - lastUIReaderAt) < 2.0 then
        return
    end
    if (now - lastUIReaderAt) < minInterval then return end

    lastUIReaderText = text
    lastUIReaderAt   = now

    DebugLog("[" .. (context or "?") .. "]", text)
    Speak(text)
end

-- ========= SettingsTooltip text extraction =========
--
-- SettingsTooltip (Dragonflight / 12.0+) may carry a .Title + .Body layout
-- rather than the classic TextLeft1 / TextRight1 structure.  We try both.

local function GetSettingsTooltipText(tip)
    if not tip then return nil end
    if tip.IsForbidden and tip:IsForbidden() then return nil end

    local parts = {}

    -- Tier A: Dragonflight+ structured title + body FontStrings
    local function tryField(f)
        if f and f.GetText then
            local t = CleanText(f:GetText())
            if t then parts[#parts + 1] = t end
        end
    end
    tryField(tip.Title)
    tryField(tip.Body)
    tryField(tip.Description)
    tryField(tip.Subtitle)

    -- Tier B: classic GameTooltip named text regions (TextLeft1, TextLeft2 …)
    if #parts == 0 then
        local tname = tip.GetName and tip:GetName()
        if tname then
            for i = 1, UiTTSDB and UiTTSDB.maxLines or 12 do
                local lFS = _G[tname .. "TextLeft"  .. i]
                local rFS = _G[tname .. "TextRight" .. i]
                if not lFS and not rFS then break end
                local l = lFS and CleanText(lFS:GetText())
                local r = rFS and CleanText(rFS:GetText())
                if l and r then parts[#parts + 1] = l .. " " .. r
                elseif l   then parts[#parts + 1] = l
                elseif r   then parts[#parts + 1] = r end
            end
        end
    end

    -- Tier C: FontString region walk sorted by Y (unnamed / addon tooltips)
    if #parts == 0 and tip.GetRegions then
        local ok, regions = pcall(function() return { tip:GetRegions() } end)
        if ok and regions then
            local lines = {}
            for _, r in ipairs(regions) do
                if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.GetText then
                    local t = CleanText(r:GetText())
                    if t then
                        lines[#lines + 1] = { text = t, y = yutil.of(r) }
                    end
                end
            end
            yutil.sort(lines)
            local maxL = UiTTSDB and UiTTSDB.maxLines or 12
            for i, l in ipairs(lines) do
                if i > maxL then break end
                parts[#parts + 1] = l.text
            end
        end
    end

    if #parts == 0 then return nil end
    return table.concat(parts, ". ")
end

-- ========= Game Menu (ESC) hooks =========

local hookedGameMenuButtons = {}

local function OnGameMenuButtonEnter(self)
    if not UiTTSDB or not UiTTSDB.readGameMenu then return end
    local text = GetButtonLabel(self)
    if text then
        DebugLog("GameMenu:", FrameName(self) or "?", "->", text)
        SpeakUILabel(text, "GameMenu")
    end
end

local function HookGameMenuButtons()
    if not GameMenuFrame then return end
    -- Buttons are pooled and rebuilt when the menu opens. Install this here
    -- too so a menu created after PLAYER_LOGIN gets the same rescan hook.
    if not GameMenuFrame.__UiTTSUIReaderMenuHooked then
        GameMenuFrame.__UiTTSUIReaderMenuHooked = true
        TryHookScript(GameMenuFrame, "OnShow", HookGameMenuButtons)
    end
    local ok, kids = pcall(function() return { GameMenuFrame:GetChildren() } end)
    if not ok then return end
    for _, child in ipairs(kids) do
        if child and not hookedGameMenuButtons[child] then
            local ot = child.GetObjectType and child:GetObjectType()
            if ot == "Button" or ot == "CheckButton" then
                hookedGameMenuButtons[child] = true
                TryHookScript(child, "OnEnter", OnGameMenuButtonEnter)
                DebugLog("Hooked GameMenu button:", FrameName(child) or tostring(child))
            end
        end
    end
end

-- ========= Settings panel control hooks =========

local hookedSettingsControls = {}
local settingsScanThrottle   = 0
local SETTINGS_SCAN_DEPTH    = 8

local function OnSettingsControlEnter(self)
    if not UiTTSDB or not UiTTSDB.readSettingsButtons then return end
    local text = GetButtonLabel(self)
    -- Fallback: some controls have their label on the parent container
    if not text then
        local parent = self.GetParent and self:GetParent()
        if parent then text = GetButtonLabel(parent) end
    end
    if text then
        DebugLog("Settings control:", FrameName(self) or "?", "->", text)
        SpeakUILabel(text, "Settings")
    end
end

local function ScanSettingsChildren(parent, depth)
    if not parent or depth > SETTINGS_SCAN_DEPTH then return end
    if parent.IsForbidden and parent:IsForbidden() then return end

    local ok, kids = pcall(function() return { parent:GetChildren() } end)
    if not ok or not kids then return end

    for _, child in ipairs(kids) do
        if child and not hookedSettingsControls[child] then
            hookedSettingsControls[child] = true

            -- Only hook frames that are likely to have readable labels
            local ot = child.GetObjectType and child:GetObjectType()
            local interesting = (ot == "Button" or ot == "CheckButton")
                or (child.GetText ~= nil)
                or (child.Text  ~= nil)
                or (child.Label ~= nil)

            if interesting then
                TryHookScript(child, "OnEnter", OnSettingsControlEnter)
            end

            ScanSettingsChildren(child, depth + 1)
        end
    end
end

local function HookSettingsPanel()
    local sp = _G.SettingsPanel
    if not sp then return end
    if sp.__UiTTSUIReaderHooked then return end
    sp.__UiTTSUIReaderHooked = true

    -- Scan once now (panel may already be open) and on every subsequent show
    TryHookScript(sp, "OnShow", function(self)
        ScanSettingsChildren(self, 0)
        -- Re-scan after a brief delay so lazily-built category lists are included
        if C_Timer and C_Timer.After then
            C_Timer.After(0.5, function() ScanSettingsChildren(sp, 0) end)
            C_Timer.After(1.5, function() ScanSettingsChildren(sp, 0) end)
        end
    end)

    -- Periodic re-scan while visible (catches controls added when switching categories)
    TryHookScript(sp, "OnUpdate", function(self)
        if not UiTTSDB or not UiTTSDB.readSettingsButtons then return end
        local now = GetTime()
        if (now - settingsScanThrottle) < 2.0 then return end
        settingsScanThrottle = now
        ScanSettingsChildren(self, 0)
    end)

    -- Initial scan if panel is already shown at hook time
    if sp.IsShown and sp:IsShown() then
        ScanSettingsChildren(sp, 0)
    end

    DebugLog("Hooked SettingsPanel")
end

-- ========= SettingsTooltip hook =========

local function HookSettingsTooltip()
    -- Known names for the settings description tooltip in WoW 10.0+ / 12.0+
    local candidates = { "SettingsTooltip", "InterfaceOptionsTooltip" }
    for _, name in ipairs(candidates) do
        local tt = _G[name]
        if tt and not tt.__UiTTSSettingsTTHooked then
            tt.__UiTTSSettingsTTHooked = true
            TryHookScript(tt, "OnShow", function(self)
                if not UiTTSDB or not UiTTSDB.readSettingsTooltips then return end
                local text = GetSettingsTooltipText(self)
                if text then
                    DebugLog(name .. " text:", text)
                    SpeakUILabel(text, "SettingsTip")
                end
            end)
            DebugLog("Hooked", name)
        end
    end
end

-- ========= Event Toast reading =========
--
-- Detects when EventToastManagerFrame.currentDisplayingToast changes or a child
-- toast frame shows, extracts its visible text, and speaks it via the standard
-- SpeakUILabel path (reusing enabled / interruptOnNew / skipSameText / minInterval).
--
-- Primary detection: OnUpdate poll on EventToastManagerFrame (throttled to
-- TOAST_POLL_INTERVAL seconds) watching currentDisplayingToast changes.
-- Reinforcement: OnShow hooks on the known pooled toast child frames.
--
-- Text extraction uses CollectFrameText (from UiTTS_NS) which recursively walks
-- the frame tree, skips decorative/model frames, and returns FontStrings sorted
-- top-to-bottom by Y position.  Lines are deduped and joined with ". ".

local TOAST_POLL_INTERVAL = 0.25   -- how often to check currentDisplayingToast (seconds)
local TOAST_TEXT_DELAY    = 0.25   -- defer after show so text finishes populating

local toastLastSpokenText  = nil   -- last text we spoke; reset when toast hides
local toastLastKnownFrame  = nil   -- last frame we saw as currentDisplayingToast
local HookToastChildFrame          -- forward declaration; defined below
local toastUpdateThrottle  = 0     -- GetTime() stamp for OnUpdate throttle

-- Named FontString fields used by Blizzard toast templates (checked before full tree walk).
local TOAST_TEXT_FIELDS = {
    "Title", "HeaderText", "Text", "DescriptionText", "SubText",
    "Label", "description", "Name",
}

-- Build a single readable string from a toast frame tree.
-- Returns nil if no non-decorative text was found.
local function BuildToastText(toastFrame)
    if not toastFrame then return nil end
    if toastFrame.IsForbidden and toastFrame:IsForbidden() then return nil end

    -- Tier 0: named FontString fields — fastest and most reliable for Blizzard templates.
    -- Many toast frames expose Title / Text / HeaderText directly as fields.
    local quickParts = {}
    local quickSeen  = {}
    for _, field in ipairs(TOAST_TEXT_FIELDS) do
        local fs = toastFrame[field]
        if fs and type(fs) == "table" and fs.GetText then
            local t = CleanText(fs:GetText())
            if t and not quickSeen[t] then
                quickSeen[t] = true
                quickParts[#quickParts + 1] = t
            end
        end
    end
    if #quickParts > 0 then
        return table.concat(quickParts, ". ")
    end

    -- Tier 1: recursive frame-tree walk (handles WidgetContainer-based toasts
    -- where text lives in pooled UIWidget child frames rather than named fields).
    return BuildSortedText(toastFrame)
end

-- Attempt to speak the text from a toast frame, respecting all dedup guards.
local function CheckAndSpeakToast(toastFrame, source)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readEventToasts then return end
    if not toastFrame then return end

    local text = BuildToastText(toastFrame)

    if not text then
        DebugLog("Toast: no text found in",
            FrameName(toastFrame) or tostring(toastFrame), "(source:", source or "?", ")")
        return
    end

    DebugLog("Toast detected [" .. (source or "?") .. "]:", text:sub(1, 100))

    if UiTTSDB.skipSameText and text == toastLastSpokenText then
        DebugLog("Toast: skipped (same as last spoken text)")
        return
    end

    toastLastSpokenText = text
    SpeakUILabel(text, "EventToast")
end

-- OnUpdate handler attached to EventToastManagerFrame.
-- Throttled; watches currentDisplayingToast for changes and text updates.
local function OnEventToastManagerUpdate(self)
    if not UiTTSDB or not UiTTSDB.readEventToasts then return end

    local now = GetTime()
    if (now - toastUpdateThrottle) < TOAST_POLL_INTERVAL then return end
    toastUpdateThrottle = now

    local current = self.currentDisplayingToast
    local isShowing = current and (not current.IsShown or current:IsShown())

    -- Fallback: if currentDisplayingToast isn't set (or the field name changed in a
    -- WoW patch), scan all visible non-decorative children of the manager frame.
    if not isShowing then
        local ok, kids = pcall(function() return { self:GetChildren() } end)
        if ok and kids then
            for _, child in ipairs(kids) do
                if child and not (child.IsForbidden and child:IsForbidden())
                    and child.IsShown and child:IsShown() then
                    -- Hook new pool entries that appeared after initial setup
                    HookToastChildFrame(child)
                    if child ~= toastLastKnownFrame then
                        DebugLog("Toast: visible child (fallback) ->", FrameName(child) or tostring(child))
                        toastLastKnownFrame = child
                        toastLastSpokenText = nil
                    end
                    CheckAndSpeakToast(child, "poll_child")
                    return
                end
            end
        end
        -- No toast found — reset state so the next toast always speaks.
        if toastLastKnownFrame then
            DebugLog("Toast: none displaying, resetting dedup state")
            toastLastKnownFrame  = nil
            toastLastSpokenText  = nil
        end
        return
    end

    if current ~= toastLastKnownFrame then
        -- New toast frame appeared; clear last-spoken so it speaks even if
        -- the text happens to match a previous toast this session.
        DebugLog("Toast: new frame ->", FrameName(current) or tostring(current))
        toastLastKnownFrame = current
        toastLastSpokenText = nil
    end

    -- Always call CheckAndSpeakToast; it handles skipSameText internally.
    -- This also catches text changes on a persistent toast frame (e.g. progress).
    CheckAndSpeakToast(current, "poll")
end

-- Hook a single child frame of EventToastManagerFrame (toast pool entry).
-- Assigned to the forward-declared local so OnEventToastManagerUpdate can call it.
HookToastChildFrame = function(child)
    if not child or child.__UiTTSToastChildHooked then return end
    child.__UiTTSToastChildHooked = true

    TryHookScript(child, "OnShow", function(self)
        if not UiTTSDB or not UiTTSDB.readEventToasts then return end
        DebugLog("Toast child OnShow:", FrameName(self) or tostring(self))
        -- Defer so the toast finishes populating its FontStrings
        if C_Timer and C_Timer.After then
            C_Timer.After(TOAST_TEXT_DELAY, function()
                if self and (not self.IsShown or self:IsShown()) then
                    -- Sync toastLastKnownFrame so the OnUpdate poll doesn't
                    -- double-speak when it catches up
                    toastLastKnownFrame = self
                    toastLastSpokenText = nil
                    CheckAndSpeakToast(self, "OnShow")
                end
            end)
        else
            toastLastKnownFrame = self
            toastLastSpokenText = nil
            CheckAndSpeakToast(self, "OnShow")
        end
    end)

    DebugLog("Hooked toast child:", FrameName(child) or tostring(child))
end

-- Main setup: hook EventToastManagerFrame and its existing child pool frames.
local function HookEventToastManager()
    local manager = _G.EventToastManagerFrame
    if not manager then
        DebugLog("EventToastManagerFrame not found")
        return
    end
    if manager.__UiTTSToastHooked then return end
    manager.__UiTTSToastHooked = true

    -- Primary detection: throttled OnUpdate watching currentDisplayingToast
    TryHookScript(manager, "OnUpdate", OnEventToastManagerUpdate)

    -- Reinforcement: hook existing pooled child toast frames (OnShow / OnHide)
    local ok, kids = pcall(function() return { manager:GetChildren() } end)
    if ok and kids then
        for _, child in ipairs(kids) do
            HookToastChildFrame(child)
        end
    end

    DebugLog("Hooked EventToastManagerFrame")
end

-- ========= PVEFrame "new content" notification reading =========
--
-- PVEFrame.NewSlice is the animated banner (e.g. "NOVA SÉRIE!", "NEW SEASON!")
-- Blizzard shows inside the Group Finder when new content is available.
-- We read it when PVEFrame opens and whenever the banner appears or changes.
-- Gated by UiTTSDB.readPVENewSlice (dedicated toggle).

local pveNewSliceLastText = nil

local function ReadPVENewSlice()
    if not UiTTSDB or not UiTTSDB.readPVENewSlice then return end
    local pve = _G.PVEFrame
    if not pve then return end
    local slice = pve.NewSlice
    if not slice or not (slice.IsShown and slice:IsShown()) then return end

    local text = nil

    -- Tier 0: named FontString fields
    for _, field in ipairs({ "Title", "HeaderText", "Text", "Label", "Description" }) do
        local fs = slice[field]
        if fs and type(fs) == "table" and fs.GetText then
            local t = CleanText(fs:GetText())
            if t then text = t; break end
        end
    end

    -- Tier 1: recursive frame-tree walk
    if not text then
        text = BuildSortedText(slice)
    end

    if not text or text == pveNewSliceLastText then return end
    pveNewSliceLastText = text
    DebugLog("PVENewSlice:", text:sub(1, 80))
    SpeakUILabel(text, "PVENewSlice")
end

local function HookPVEFrame()
    local pve = _G.PVEFrame
    if not pve or pve.__UiTTSPVEHooked then return end
    pve.__UiTTSPVEHooked = true

    -- Re-opening the frame always reads so new-season banners aren't silenced.
    TryHookScript(pve, "OnShow", function(self)
        pveNewSliceLastText = nil
        if C_Timer and C_Timer.After then
            C_Timer.After(0.3, ReadPVENewSlice)
        else
            ReadPVENewSlice()
        end
    end)

    -- Hook NewSlice.OnShow so the banner speaks even if PVEFrame was already open.
    local slice = pve.NewSlice
    if slice and not slice.__UiTTSPVESliceHooked then
        slice.__UiTTSPVESliceHooked = true
        TryHookScript(slice, "OnShow", function(self)
            pveNewSliceLastText = nil
            if C_Timer and C_Timer.After then
                C_Timer.After(0.25, ReadPVENewSlice)
            else
                ReadPVENewSlice()
            end
        end)
    end

    DebugLog("Hooked PVEFrame")
end

-- ========= PlayerChoice reading =========
--
-- Speaks the visible text of the hovered option/card in the PlayerChoice
-- window (Blizzard_PlayerChoice).  Each card is a direct child of
-- PlayerChoiceFrame; hovering any part of a card (including mouse-intercepting
-- sub-frames such as model scenes or select buttons) triggers a read of that
-- card's full text once per hover.
--
-- Detection strategy:
--   1. Hook OnEnter / OnLeave on every non-model descendant of PlayerChoiceFrame
--      up to CHOICE_HOOK_DEPTH levels deep (catches both the card frame itself
--      and children that intercept mouse events).
--   2. In every OnEnter handler, walk up the parent chain to find the direct
--      child of PlayerChoiceFrame (the "card") and extract text from it.
--   3. A tiny deferred-leave timer prevents rapid child-boundary crossings
--      within the same card from triggering repeated speech.
--
-- Text extraction reuses CollectFrameText (UiTTS_NS) which skips decorative
-- and model frames and sorts FontStrings top-to-bottom by Y position.

local CHOICE_HOOK_DEPTH  = 2    -- how many levels deep to hook below each option card
local CHOICE_LEAVE_DELAY = 0.08 -- seconds to wait after OnLeave before clearing hover state

-- Per-session state (cleared whenever the frame hides or a new choice is presented)
local pcLastHoveredCard = nil   -- card frame currently under the mouse
local pcLastSpokenText  = nil   -- last text spoken for any card this session
local pcLeavePending    = false -- true if a leave-debounce timer is in flight
local pcLeaveForCard    = nil   -- which card the pending leave is for

-- Isolated dedup for PlayerChoice speech.  Kept separate from SpeakUILabel's
-- lastUIReaderText/lastUIReaderAt so that speaking a card does NOT suppress
-- GameMenu, EventToast, SettingsTooltip, or other UIReader features.
local pcLastSpeakText = nil
local pcLastSpeakAt   = 0

-- Returns true only if `frame` is already mouse-interactive (Button/CheckButton
-- by type, or any frame with EnableMouse explicitly set to true).
-- This is the key guard that prevents us from accidentally enabling mouse events
-- on decorative/text-only child frames, which would cause them to sit on top of
-- the actual ChooseButton and intercept clicks.
local function IsPCFrameMouseEnabled(frame)
    if not frame then return false end
    -- pcall on both: a *protected* frame raises "Attempt to access forbidden
    -- object from code tainted by an AddOn" on any C method, and IsForbidden()
    -- does not predict it (Blizzard_CatalogShop's ScrollBoxListView row buttons
    -- are reachable yet refuse the call). Unknown means "not hookable".
    if frame.GetObjectType then
        local ok, ot = pcall(frame.GetObjectType, frame)
        if not ok then return false end
        if ot == "Button" or ot == "CheckButton" then return true end
    end
    if not frame.IsMouseEnabled then return false end
    local ok, enabled = pcall(frame.IsMouseEnabled, frame)
    return ok and enabled == true
end

-- Walk up the parent chain from `frame` to find its direct-child-of-PlayerChoiceFrame
-- ancestor.  Returns nil if `frame` is not inside PlayerChoiceFrame.
local function FindChoiceCardAncestor(frame)
    local pcf = _G.PlayerChoiceFrame
    if not pcf or not frame then return nil end
    local f = frame
    for _ = 1, 10 do
        if not f then return nil end
        local parent = f.GetParent and f:GetParent()
        if parent == pcf then return f end
        f = parent
    end
    return nil
end

-- Isolated speak path for PlayerChoice.  Uses pcLastSpeakText/pcLastSpeakAt
-- instead of the shared SpeakUILabel state, so a card read cannot suppress
-- other UIReader features (GameMenu, EventToast, etc.) within the 2-second
-- same-text dedup window.
local function SpeakPlayerChoice(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end
    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if UiTTSDB.skipSameText and text == pcLastSpeakText
        and (now - pcLastSpeakAt) < 2.0 then
        DebugLog("PlayerChoice: isolated dedup — skipped identical text")
        return
    end
    if (now - pcLastSpeakAt) < minInterval then
        DebugLog("PlayerChoice: isolated minInterval — skipped")
        return
    end
    pcLastSpeakText = text
    pcLastSpeakAt   = now
    DebugLog("[PlayerChoice]", text:sub(1, 80))
    Speak(text)
end

-- Build readable text from a single option card frame tree.
local function BuildPlayerChoiceCardText(cardFrame)
    if not cardFrame then return nil end
    if cardFrame.IsForbidden and cardFrame:IsForbidden() then return nil end
    return BuildSortedText(cardFrame)
end

-- Cancel any in-flight leave-debounce (called from OnEnter so crossing child
-- boundaries within the same card does not accidentally clear hover state).
local function CancelPCLeave()
    pcLeavePending = false
    pcLeaveForCard = nil
end

-- OnEnter handler attached to each hooked PlayerChoice descendant.
local function OnChoiceDescendantEnter(self)
    CancelPCLeave()

    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readPlayerChoice then return end

    -- Prefer the card tag set at scan time (__UiTTSPCCard); it is more reliable
    -- than FindChoiceCardAncestor when options are nested inside a container frame
    -- (where both options would otherwise resolve to the same direct-PCF child).
    local card = self.__UiTTSPCCard or FindChoiceCardAncestor(self)
    if not card then
        DebugLog("PlayerChoice: OnEnter — no card for",
            FrameName(self) or tostring(self))
        return
    end

    DebugLog("PlayerChoice: entered card", FrameName(card) or tostring(card),
        "via", FrameName(self) or tostring(self))

    -- Guard: still on the same card — do nothing (prevents re-read when crossing
    -- child-frame boundaries within the same option without an intervening leave).
    if card == pcLastHoveredCard then return end

    pcLastHoveredCard = card

    local text = BuildPlayerChoiceCardText(card)
    if not text then
        DebugLog("PlayerChoice: no text found in card",
            FrameName(card) or tostring(card))
        return
    end

    DebugLog("PlayerChoice card text:", text:sub(1, 120))

    if UiTTSDB.skipSameText and text == pcLastSpokenText then
        DebugLog("PlayerChoice: skipped (same text as last spoken card)")
        return
    end

    pcLastSpokenText = text
    SpeakPlayerChoice(text)
end

-- OnLeave handler.  We use a short deferred clear rather than an immediate one
-- so that rapidly crossing child-frame borders within the same card does not
-- clear pcLastHoveredCard and trigger a re-read on the next OnEnter.
local function OnChoiceDescendantLeave(self)
    local card = FindChoiceCardAncestor(self) or self

    DebugLog("PlayerChoice: leave from", FrameName(self) or tostring(self),
        "card:", FrameName(card) or "?")

    -- Record which card this leave belongs to, then defer the clear.
    pcLeavePending = true
    pcLeaveForCard = card

    if C_Timer and C_Timer.After then
        C_Timer.After(CHOICE_LEAVE_DELAY, function()
            -- If pcLeavePending is still set for this same card, the mouse
            -- genuinely left the card (no matching OnEnter cancelled it).
            if pcLeavePending and pcLeaveForCard == card then
                pcLeavePending    = false
                pcLeaveForCard    = nil
                pcLastHoveredCard = nil
                DebugLog("PlayerChoice: hover state cleared (mouse left card)")
            end
        end)
    else
        -- No timer API — clear immediately (might cause minor re-reads)
        pcLastHoveredCard = nil
    end
end

-- Names of direct children of PlayerChoiceFrame that are purely decorative and
-- should not receive OnEnter hooks.  Checked against the trailing name segment.
local PC_SKIP_DIRECT = {
    Background = true, Artwork = true, ArtworkBorder = true,
    BorderLayerModelScene = true, CloseButton = true, TitleContainer = true,
    NineSlice = true,
}

-- Recursively hook OnEnter / OnLeave on non-model descendants of `parentFrame`,
-- stopping at CHOICE_HOOK_DEPTH levels below the option-card level.
-- `depth` starts at 0 when called with PlayerChoiceFrame directly.
-- `cardAncestor` is nil at depth 0; at depth 1+ it is the depth-0 child whose
-- subtree we are currently inside.  Each hooked frame gets `__UiTTSPCCard` set
-- to that ancestor so that OnEnter can identify the correct card without relying
-- solely on FindChoiceCardAncestor (which can collapse both options into one frame
-- when options are wrapped in a container that is the direct child of PCF).
local function ScanAndHookChoiceDescendants(parentFrame, depth, cardAncestor)
    if not parentFrame or depth > CHOICE_HOOK_DEPTH then return end
    if parentFrame.IsForbidden and parentFrame:IsForbidden() then return end

    local ok, kids = pcall(function() return { parentFrame:GetChildren() } end)
    if not ok or not kids then return end

    for _, child in ipairs(kids) do
        if child and not child.__UiTTSPCHooked then
            local skip = false

            -- Skip model/cinematic object types
            local ot = child.GetObjectType and child:GetObjectType()
            if ot == "Model" or ot == "PlayerModel" or ot == "CinematicModel"
                or ot == "DressUpModel" or ot == "TabardModel" then
                skip = true
            end

            -- Skip frames whose trailing name segment is known-decorative
            if not skip then
                local name = FrameName(child)
                if name then
                    local tail = name:match("[^%.]+$") or name
                    if depth == 0 and PC_SKIP_DIRECT[tail] then
                        skip = true
                    elseif tail:find("ModelScene") or tail:find("Model", 1, true) then
                        skip = true
                    end
                end
            end

            -- KEY FIX: only hook frames that are already mouse-interactive.
            -- Attaching HookScript("OnEnter") to a non-mouse-enabled Frame can
            -- implicitly enable mouse events on it, turning decorative/text-only
            -- frames into click interceptors that sit over the ChooseButton.
            if not skip and not IsPCFrameMouseEnabled(child) then
                DebugLog("PlayerChoice: skip (not mouse-enabled, depth " .. depth .. ")",
                    FrameName(child) or tostring(child),
                    "type:", child.GetObjectType and child:GetObjectType() or "?")
                skip = true
            end

            if not skip then
                -- At depth 0 the child IS the option card.
                -- At depth 1+ the card is the depth-0 ancestor passed down.
                local thisCard = cardAncestor or child

                child.__UiTTSPCHooked = true
                child.__UiTTSPCCard   = thisCard   -- tag used by OnChoiceDescendantEnter

                TryHookScript(child, "OnEnter", OnChoiceDescendantEnter)
                TryHookScript(child, "OnLeave", OnChoiceDescendantLeave)
                DebugLog("PlayerChoice: hooked (depth " .. depth .. ")",
                    FrameName(child) or tostring(child),
                    "-> card:", FrameName(thisCard) or tostring(thisCard))

                -- Recurse, passing the card context down
                ScanAndHookChoiceDescendants(child, depth + 1, thisCard)
            end
        end
    end
end

-- Main setup: attach to PlayerChoiceFrame.  Idempotent via __UiTTSPCHooked.
local function HookPlayerChoiceFrame()
    local pcf = _G.PlayerChoiceFrame
    if not pcf then
        DebugLog("PlayerChoiceFrame not found")
        return
    end
    if pcf.__UiTTSPCHooked then return end
    pcf.__UiTTSPCHooked = true

    DebugLog("Hooking PlayerChoiceFrame")

    -- Hook the frame's show/hide lifecycle
    TryHookScript(pcf, "OnShow", function(self)
        DebugLog("PlayerChoiceFrame OnShow — resetting dedup state")
        -- New choice presentation: clear all per-session state so the first
        -- hover always speaks, even if the text matches a previous choice.
        CancelPCLeave()
        pcLastHoveredCard = nil
        pcLastSpokenText  = nil
        pcLastSpeakText   = nil
        pcLastSpeakAt     = 0

        -- Blizzard populates the option cards asynchronously after OnShow, so
        -- defer the descendant scan to let the children be fully built.
        if C_Timer and C_Timer.After then
            C_Timer.After(0.15, function()
                if self and (not self.IsShown or self:IsShown()) then
                    ScanAndHookChoiceDescendants(self, 0)
                end
            end)
            -- Second pass for slow builds
            C_Timer.After(0.5, function()
                if self and (not self.IsShown or self:IsShown()) then
                    ScanAndHookChoiceDescendants(self, 0)
                end
            end)
        else
            ScanAndHookChoiceDescendants(self, 0)
        end
    end)

    TryHookScript(pcf, "OnHide", function()
        DebugLog("PlayerChoiceFrame OnHide — clearing state")
        CancelPCLeave()
        pcLastHoveredCard = nil
        pcLastSpokenText  = nil
        pcLastSpeakText   = nil
        pcLastSpeakAt     = 0
    end)

    -- Scan existing children now in case the frame is already shown
    ScanAndHookChoiceDescendants(pcf, 0)
    if pcf.IsShown and pcf:IsShown() then
        DebugLog("PlayerChoiceFrame already visible — immediate scan")
    end

    DebugLog("HookPlayerChoiceFrame complete")
end

-- ========= Scenario / Objective Tracker reading =========
--
-- Detects when a timed scenario/event tracker appears and:
--   1. Speaks the full visible content once on first appearance.
--   2. Announces time milestones: "MM:SS Tempo restante" as the countdown
--      crosses 02:45, 02:30, 02:15, 02:00, 01:45, 01:30, 01:15, 01:00,
--      00:45, 00:30, 00:15, 00:05.
--   3. Announces progress milestones: "N de M coletados." at 01:50, 00:50,
--      00:10 remaining.
--
-- Detection: OnShow/OnHide hooks on the tracker frame; a C_Timer.NewTicker
-- runs each scanInterval seconds to parse the countdown and check milestones.
-- All speech routes through SpeakUILabel (reuses enabled / interruptOnNew /
-- skipSameText / minInterval guards).

-- Time milestones in descending seconds (02:45 = 165, … 00:05 = 5)
local ST_TIME_MILESTONES     = {165, 150, 135, 120, 105, 90, 75, 60, 45, 30, 15, 5}
-- Progress milestones in descending seconds (01:50 = 110, 00:50 = 50, 00:10 = 10)
local ST_PROGRESS_MILESTONES = {110, 50, 10}

local stPollTicker         = nil   -- C_Timer.NewTicker handle (cancel with :Cancel())
local stPrevSecs           = nil   -- timer value from previous tick; nil until first tick
local stInitialSpoken      = false -- true after the one-time full-content read
local stTimeMilestones     = {}    -- [seconds] = true once announced this event
local stProgressMilestones = {}    -- [seconds] = true once announced this event

-- Parse "MM:SS" or bare "SS" from `text`; return integer seconds or nil.
local function ParseTimerSecs(text)
    if type(text) ~= "string" then return nil end
    local m, s = text:match("(%d+):(%d+)")
    if m and s then return tonumber(m) * 60 + tonumber(s) end
    local bare = text:match("^%s*(%d+)%s*$")
    if bare then return tonumber(bare) end
    return nil
end

-- Parse "N/M" fractions in `text`; return the pair with the largest goal, or nil, nil.
local function ParseProgress(text)
    if type(text) ~= "string" then return nil, nil end
    local bestCur, bestGoal = nil, nil
    for cur, goal in text:gmatch("(%d+)/(%d+)") do
        local c, g = tonumber(cur), tonumber(goal)
        if c and g and g > 0 and (not bestGoal or g > bestGoal) then
            bestCur, bestGoal = c, g
        end
    end
    return bestCur, bestGoal
end

-- Collect, sort (top→bottom), and deduplicate text lines from `frame` tree.
-- Returns a plain string table (no {text,y} pairs).
local function CollectTrackerLines(frame)
    if not frame or not CollectFrameText then return {} end
    local raw = CollectFrameText(frame, {}, 0, {})
    if #raw == 0 then return {} end
    yutil.sort(raw)
    local seen = {}
    local out  = {}
    local maxL = (UiTTSDB and UiTTSDB.maxLines) or 12
    for _, l in ipairs(raw) do
        if #out >= maxL then break end
        if not seen[l.text] then
            seen[l.text] = true
            out[#out + 1] = l.text
        end
    end
    return out
end

-- Return the first MM:SS timer value found in the frame tree, in seconds, or nil.
local function FindTrackerTimer(frame)
    for _, t in ipairs(CollectTrackerLines(frame)) do
        local secs = ParseTimerSecs(t)
        if secs then return secs end
    end
    return nil
end

-- Return the N/M progress pair with the largest goal found in the frame tree, or nil, nil.
local function FindTrackerProgress(frame)
    for _, t in ipairs(CollectTrackerLines(frame)) do
        local c, g = ParseProgress(t)
        if c and g then return c, g end
    end
    return nil, nil
end

-- Build full readable text for the initial announce.
local function BuildTrackerFullText(frame)
    local lines = CollectTrackerLines(frame)
    if #lines == 0 then return nil end
    return table.concat(lines, ". ")
end

-- Clear all per-event milestone tracking state.
local function ResetTrackerState()
    stPrevSecs           = nil
    stInitialSpoken      = false
    stTimeMilestones     = {}
    stProgressMilestones = {}
    DebugLog("ScenarioTracker: state reset")
end

-- Stop the poll ticker.
local function StopTrackerPoll()
    if stPollTicker then
        pcall(function() stPollTicker:Cancel() end)
        stPollTicker = nil
        DebugLog("ScenarioTracker: poll stopped")
    end
end

-- Check time and progress milestones for a single tick.
-- Fired only when stPrevSecs is established (second tick onward).
-- Uses >= / < so a timer that starts exactly at a threshold still fires.
local function CheckTrackerMilestones(frame, prevSecs, currentSecs)
    for _, m in ipairs(ST_TIME_MILESTONES) do
        if not stTimeMilestones[m] and prevSecs >= m and currentSecs < m then
            stTimeMilestones[m] = true
            local fmt = (L and L["00:%02d:%02d time remaining"]) or "00:%02d:%02d time remaining"
            local ann = string.format(fmt, math.floor(m / 60), m % 60)
            DebugLog("ScenarioTracker time milestone:", ann)
            SpeakUILabel(ann, "ScenarioTracker")
        end
    end
    for _, m in ipairs(ST_PROGRESS_MILESTONES) do
        if not stProgressMilestones[m] and prevSecs >= m and currentSecs < m then
            stProgressMilestones[m] = true
            local cur, goal = FindTrackerProgress(frame)
            if cur and goal then
                local fmt = (L and L["%d of %d collected."]) or "%d of %d collected."
                local ann = string.format(fmt, cur, goal)
                DebugLog("ScenarioTracker progress milestone:", ann)
                SpeakUILabel(ann, "ScenarioTracker")
            end
        end
    end
end

-- Start polling `frame`.  Stops any existing ticker first.
local function StartTrackerPoll(frame)
    StopTrackerPoll()
    if not frame then return end

    local interval = math.max(0.2,
        tonumber(UiTTSDB and UiTTSDB.scanInterval) or 1.0)

    DebugLog("ScenarioTracker: poll started on",
        FrameName(frame) or tostring(frame), "every", interval, "s")

    stPollTicker = C_Timer.NewTicker(interval, function()
        if not UiTTSDB or not UiTTSDB.readScenarioTrackerEvents then return end

        -- Stop if the tracked frame has gone invisible
        if not frame or (frame.IsShown and not frame:IsShown()) then
            DebugLog("ScenarioTracker: frame gone — stopping")
            StopTrackerPoll()
            ResetTrackerState()
            return
        end

        -- First tick: speak full content and establish stPrevSecs baseline.
        -- Return early; milestone checks start on the second tick.
        if not stInitialSpoken then
            local fullText = BuildTrackerFullText(frame)
            if fullText then
                DebugLog("ScenarioTracker initial read:", fullText:sub(1, 120))
                SpeakUILabel(fullText, "ScenarioTracker")
                stInitialSpoken = true
            else
                DebugLog("ScenarioTracker: no text yet, will retry next tick")
            end
            stPrevSecs = FindTrackerTimer(frame)
            return
        end

        local currentSecs = FindTrackerTimer(frame)
        if not currentSecs then
            DebugLog("ScenarioTracker: no timer visible this tick")
            return
        end

        -- Detect a new timed event while the frame stays visible (timer jumps up)
        if stPrevSecs and currentSecs > stPrevSecs + 10 then
            DebugLog("ScenarioTracker: timer jumped — new event, resetting milestones")
            stTimeMilestones     = {}
            stProgressMilestones = {}
            stInitialSpoken      = false
            stPrevSecs           = currentSecs
            return
        end

        if stPrevSecs then
            CheckTrackerMilestones(frame, stPrevSecs, currentSecs)
        end
        stPrevSecs = currentSecs
    end)
end

-- Hook `frame` for show/hide lifecycle.  Idempotent via __UiTTSSTHooked.
local function HookTrackerFrame(frame)
    if not frame or frame.__UiTTSSTHooked then return end
    frame.__UiTTSSTHooked = true

    DebugLog("ScenarioTracker: hooking", FrameName(frame) or tostring(frame))

    TryHookScript(frame, "OnShow", function(self)
        if not UiTTSDB or not UiTTSDB.readScenarioTrackerEvents then return end
        DebugLog("ScenarioTracker OnShow:", FrameName(self) or tostring(self))
        ResetTrackerState()
        -- Short defer so frame content is fully populated before first read
        C_Timer.After(0.3, function()
            if self and (not self.IsShown or self:IsShown()) then
                StartTrackerPoll(self)
            end
        end)
    end)

    TryHookScript(frame, "OnHide", function(self)
        DebugLog("ScenarioTracker OnHide:", FrameName(self) or tostring(self))
        StopTrackerPoll()
        ResetTrackerState()
    end)

    -- If already visible at hook time, start polling immediately
    if frame.IsShown and frame:IsShown() then
        DebugLog("ScenarioTracker: already visible — starting poll")
        ResetTrackerState()
        C_Timer.After(0.3, function()
            if frame and (not frame.IsShown or frame:IsShown()) then
                StartTrackerPoll(frame)
            end
        end)
    end
end

-- Main setup: find and hook all known scenario/objective tracker frames.
local function HookScenarioTracker()
    -- ScenarioObjectiveTracker: primary frame for timed world events / scenarios
    local sot = _G.ScenarioObjectiveTracker
    if sot then
        HookTrackerFrame(sot)
        -- Inner ContentsFrame holds the actual text widgets in many layouts
        if sot.ContentsFrame then
            HookTrackerFrame(sot.ContentsFrame)
        end
    end

    -- ObjectiveTrackerUIWidgetContainer: UI-widget-based objective display
    local owc = _G.ObjectiveTrackerUIWidgetContainer
    if owc then HookTrackerFrame(owc) end

    if not sot and not owc then
        DebugLog("ScenarioTracker: no tracker frames found yet")
    end
end

-- ========= UIErrorsFrame / center-screen messages =========
--
-- Speaks short messages displayed in UIErrorsFrame — the red "action failed",
-- yellow warning, and white informational messages near the screen center.
--
-- Primary hook: WoW system events UI_ERROR_MESSAGE and UI_INFO_MESSAGE.
--   These fire for every standard Blizzard error/info message at the API level,
--   before UIErrorsFrame renders the text.  Args: (messageType, messageText).
-- Secondary hook: hooksecurefunc on UIErrorsFrame:AddMessage, catching any
--   messages written directly to the frame by addons (bypassing events).
--   The 3-second same-text dedup window in SpeakUIError prevents double-speaking
--   when both hooks fire for the same message.
--
-- Isolated dedup state ensures this feature cannot suppress tooltip TTS or
-- other UIReader features.

local UI_ERR_DEDUP_WINDOW = 3.0   -- suppress identical messages within this window (s)

local uiErrLastText = nil
local uiErrLastAt   = 0

local function SpeakUIError(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readUIErrors then return end
    if not text then return end

    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0

    if UiTTSDB.skipSameText and text == uiErrLastText
        and (now - uiErrLastAt) < UI_ERR_DEDUP_WINDOW then
        DebugLog("UIErrors: dedup skip (same text within "
            .. UI_ERR_DEDUP_WINDOW .. "s):", text:sub(1, 60))
        return
    end

    if (now - uiErrLastAt) < minInterval then
        DebugLog("UIErrors: minInterval skip (", minInterval, "s)")
        return
    end

    uiErrLastText = text
    uiErrLastAt   = now
    DebugLog("UIErrors: speaking:", text:sub(1, 80))
    Speak(text)
end

-- Hooks UIErrorsFrame:AddMessage as a catch-all for addon-generated messages
-- that bypass the event system.  Called once from PLAYER_LOGIN after the frame
-- is guaranteed to exist.  Idempotent via __UiTTSUIErrHooked.
local function HookUIErrorsFrame()
    local uief = _G.UIErrorsFrame
    if not uief then
        DebugLog("UIErrors: UIErrorsFrame not found — AddMessage hook skipped")
        return
    end
    if uief.__UiTTSUIErrHooked then return end
    uief.__UiTTSUIErrHooked = true

    -- hooksecurefunc is a post-hook that does not taint the frame.
    -- The first arg is the message string; the rest are color components (r, g, b).
    local ok = pcall(hooksecurefunc, uief, "AddMessage", function(_, msg)
        if not UiTTSDB or not UiTTSDB.readUIErrors then return end
        local text = CleanText(msg)
        if not text then return end
        DebugLog("UIErrors: AddMessage hook:", text:sub(1, 80))
        -- SpeakUIError's dedup window suppresses double-speak when the same
        -- message already came through the UI_ERROR_MESSAGE event path.
        SpeakUIError(text)
    end)

    if ok then
        DebugLog("UIErrors: hooked UIErrorsFrame:AddMessage (catch-all)")
    else
        DebugLog("UIErrors: AddMessage hooksecurefunc failed — events only")
    end
end

-- ========= Raid warnings / boss emotes (RaidNotice frames) =========
--
-- Speaks the large center-screen announcements WoW shows on RaidWarningFrame
-- and RaidBossEmoteFrame: raid warnings (/rw), boss emotes and whispers, and
-- the scenario / quest event announcements Blizzard pushes there directly
-- (e.g. "A CORRUPÇÃO RECONSTITUIU O HOSPEDEIRO!").
--
-- Primary hook: RaidNotice_AddMessage — the single global funnel every caller
--   goes through to put a message on one of those frames.
-- Secondary hook: AddMessage on each frame, for callers that write to the frame
--   directly. Both hooks fire for the same message (RaidNotice_AddMessage calls
--   frame:AddMessage), so the short duplicate guard below is unconditional.
--
-- Gated by UiTTSDB.readRaidWarning, with isolated dedup state.

local RW_DUPLICATE_WINDOW = 0.5   -- guaranteed double-fire of the two hooks (s)
local RW_DEDUP_WINDOW     = 3.0   -- skipSameText window for repeats (s)

local rwLastText  = nil
local rwLastAt    = 0
local rwHookDone  = false

local function SpeakRaidWarning(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readRaidWarning then return end
    if not text then return end

    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0

    if text == rwLastText and (now - rwLastAt) < RW_DUPLICATE_WINDOW then
        DebugLog("RaidWarning: duplicate hook — skipped")
        return
    end
    if UiTTSDB.skipSameText and text == rwLastText
        and (now - rwLastAt) < RW_DEDUP_WINDOW then
        DebugLog("RaidWarning: dedup skip (same text):", text:sub(1, 60))
        return
    end
    if (now - rwLastAt) < minInterval then
        DebugLog("RaidWarning: minInterval skip")
        return
    end

    rwLastText = text
    rwLastAt   = now
    DebugLog("RaidWarning: speaking:", text:sub(1, 80))
    Speak(text)
end

-- True for the frames whose messages we want: the raid warning banner and the
-- boss emote line right below it. Other RaidNotice-style frames are ignored.
local function IsRaidNoticeFrame(frame)
    if not frame then return false end
    return frame == _G.RaidWarningFrame or frame == _G.RaidBossEmoteFrame
end

local function HookRaidWarningFrames()
    if rwHookDone then return true end
    local rwf = _G.RaidWarningFrame
    local rbf = _G.RaidBossEmoteFrame
    if not rwf and not rbf then return false end
    rwHookDone = true

    -- RaidNotice_AddMessage(noticeFrame, textString, colorInfo, displayQueued)
    if type(_G.RaidNotice_AddMessage) == "function" then
        local ok = pcall(hooksecurefunc, "RaidNotice_AddMessage", function(frame, msg)
            if not UiTTSDB or not UiTTSDB.readRaidWarning then return end
            if not IsRaidNoticeFrame(frame) then return end
            local text = CleanText(msg)
            if not text then return end
            DebugLog("RaidWarning: RaidNotice_AddMessage hook:", text:sub(1, 80))
            SpeakRaidWarning(text)
        end)
        DebugLog("RaidWarning: RaidNotice_AddMessage hook",
            ok and "installed" or "failed")
    end

    -- Catch-all per frame, for messages written straight to the frame. Built
    -- with explicit inserts: a nil hole would cut the ipairs walk short.
    local frames = {}
    if rwf then frames[#frames + 1] = rwf end
    if rbf then frames[#frames + 1] = rbf end
    for _, frame in ipairs(frames) do
        if not frame.__UiTTSRaidWarnHooked then
            frame.__UiTTSRaidWarnHooked = true
            pcall(hooksecurefunc, frame, "AddMessage", function(_, msg)
                if not UiTTSDB or not UiTTSDB.readRaidWarning then return end
                local text = CleanText(msg)
                if not text then return end
                DebugLog("RaidWarning: AddMessage hook:", text:sub(1, 80))
                SpeakRaidWarning(text)
            end)
        end
    end

    DebugLog("RaidWarning: hook setup complete")
    return true
end

-- ========= Info Panel Reader =========
--
-- Reads visible text from large Blizzard information/detail panels (e.g. the
-- Allied Races description panel) when the mouse hovers the readable content area.
--
-- Gated by UiTTSDB.readInfoPanels.  Uses CollectFrameText (UiTTS_NS) to
-- extract visible FontStrings from the content frame's subtree, skipping
-- decorative/model frames and sorting top-to-bottom by Y position.
--
-- Dedup strategy (isolated from SpeakUILabel and SpeakPlayerChoice):
--   • A per-contentFrame "hovering" flag suppresses repeated reads while the
--     mouse stays inside the same panel area.
--   • A short leave-debounce (IP_LEAVE_DELAY) lets the mouse cross inner frame
--     boundaries without falsely clearing the hover state.
--   • Re-entering after leaving always re-reads (ipLastSpeakTxt cleared on leave).
--   • Isolated dedup (ipLastSpeakTxt / ipLastSpeakAt) prevents info panel reads
--     from suppressing tooltip, GameMenu, EventToast, or other UIReader features.
--
-- AlliedRacesFrame targeting:
--   triggerFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame   (mouse-enabled)
--   contentFrame = AlliedRacesFrame.RaceInfoFrame               (text subtree)
--   Hooked lazily via ADDON_LOADED "Blizzard_AlliedRaces".
--   Secondary pass also hooks any other mouse-enabled children of RaceInfoFrame
--   (title, requirements, ability buttons) so the whole panel is covered.

local IP_LEAVE_DELAY = 0.10   -- seconds after OnLeave before hover state clears
local IP_ENTER_DELAY = 0.15   -- defer first read so frame text is fully populated

-- Isolated speak-path dedup (separate from SpeakUILabel and SpeakPlayerChoice states)
local ipLastSpeakTxt = nil
local ipLastSpeakAt  = 0

local function SpeakInfoPanel(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end
    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if UiTTSDB.skipSameText and text == ipLastSpeakTxt
        and (now - ipLastSpeakAt) < 2.0 then
        DebugLog("InfoPanel: isolated dedup — skipped identical text")
        return
    end
    if (now - ipLastSpeakAt) < minInterval then
        DebugLog("InfoPanel: minInterval — skipped")
        return
    end
    ipLastSpeakTxt = text
    ipLastSpeakAt  = now
    DebugLog("[InfoPanel]", text:sub(1, 120))
    Speak(text)
end

-- Extract readable text from a content frame's subtree.
local function BuildInfoPanelText(contentFrame)
    if not contentFrame then return nil end
    if contentFrame.IsForbidden and contentFrame:IsForbidden() then return nil end
    return BuildSortedText(contentFrame)
end

-- Per-contentFrame hover state, keyed by contentFrame.  Shared across all
-- trigger frames that read from the same content frame, so that moving the
-- mouse between inner hooked children does not falsely re-trigger a read.
local ipHoverState = {}

local function GetIPState(contentFrame)
    local st = ipHoverState[contentFrame]
    if not st then
        st = { hovering = false, leavePending = false }
        ipHoverState[contentFrame] = st
    end
    return st
end

-- Attach OnEnter/OnLeave to triggerFrame so hovering it speaks the text
-- collected from contentFrame's subtree.  Idempotent via __UiTTSIPHooked.
-- `label` is used for debug output only.
local function HookInfoPanelTrigger(triggerFrame, contentFrame, label)
    if not triggerFrame or triggerFrame.__UiTTSIPHooked then return end
    triggerFrame.__UiTTSIPHooked = true

    TryHookScript(triggerFrame, "OnEnter", function(self)
        if not UiTTSDB or not UiTTSDB.readInfoPanels then return end

        local st = GetIPState(contentFrame)

        -- Cancel any pending leave-debounce (mouse crossed an inner boundary)
        st.leavePending = false

        -- Already hovering this content area — suppress repeated reads
        if st.hovering then
            DebugLog("InfoPanel [" .. label .. "]: enter — already hovering, skip")
            return
        end
        st.hovering = true

        DebugLog("InfoPanel [" .. label .. "]: OnEnter via",
            FrameName(self) or tostring(self))

        if C_Timer and C_Timer.After then
            C_Timer.After(IP_ENTER_DELAY, function()
                local st2 = GetIPState(contentFrame)
                if not st2.hovering then return end
                if not UiTTSDB or not UiTTSDB.readInfoPanels then return end
                local text = BuildInfoPanelText(contentFrame)
                if not text then
                    DebugLog("InfoPanel [" .. label .. "]: no text extracted")
                    return
                end
                DebugLog("InfoPanel [" .. label .. "]: text =", text:sub(1, 120))
                SpeakInfoPanel(text)
            end)
        else
            local text = BuildInfoPanelText(contentFrame)
            if text then
                DebugLog("InfoPanel [" .. label .. "]: text =", text:sub(1, 120))
                SpeakInfoPanel(text)
            end
        end
    end)

    TryHookScript(triggerFrame, "OnLeave", function(self)
        local st = GetIPState(contentFrame)
        st.leavePending = true
        DebugLog("InfoPanel [" .. label .. "]: OnLeave from",
            FrameName(self) or tostring(self))

        if C_Timer and C_Timer.After then
            C_Timer.After(IP_LEAVE_DELAY, function()
                local st2 = GetIPState(contentFrame)
                if st2.leavePending then
                    st2.leavePending = false
                    st2.hovering = false
                    -- Clear isolated dedup so re-entering after leaving always
                    -- reads, even when panel text has not changed.
                    ipLastSpeakTxt = nil
                    DebugLog("InfoPanel [" .. label .. "]: hover state cleared")
                end
            end)
        else
            local st2 = GetIPState(contentFrame)
            st2.hovering = false
            ipLastSpeakTxt = nil
        end
    end)

    DebugLog("InfoPanel: hooked trigger",
        FrameName(triggerFrame) or tostring(triggerFrame),
        "reads from", FrameName(contentFrame) or tostring(contentFrame),
        "(", label, ")")
end

-- Scan mouse-enabled non-decorative children of parentFrame and hook them as
-- additional info-panel triggers for contentFrame.  Stops at depth 2 to keep
-- the scan bounded.  Skips frames already hooked (__UiTTSIPHooked).
local function ScanInfoPanelChildren(parentFrame, contentFrame, label, depth)
    depth = depth or 0
    if depth > 2 then return end
    if not parentFrame or (parentFrame.IsForbidden and parentFrame:IsForbidden()) then return end

    local ok, kids = pcall(function() return { parentFrame:GetChildren() } end)
    if not ok or not kids then return end

    for _, child in ipairs(kids) do
        if child and not child.__UiTTSIPHooked then
            local ot = child.GetObjectType and child:GetObjectType()

            -- Skip model/cinematic object types entirely (3D race preview, etc.)
            if ot ~= "Model" and ot ~= "PlayerModel" and ot ~= "CinematicModel"
                and ot ~= "DressUpModel" and ot ~= "TabardModel" then

                -- Skip frames whose trailing name segment looks decorative
                local name = FrameName(child)
                local tail = name and (name:match("[^%.]+$") or name) or ""
                local skip = tail:find("Model", 1, true) or tail:find("ModelScene")
                    or tail:find("Background") or tail:find("Backdrop")
                    or tail:find("Artwork")    or tail:find("NineSlice")
                    or tail:find("Border")     or tail:find("Shadow")
                    or tail:find("CloseButton")

                if not skip then
                    -- Only hook frames already mouse-interactive (Button, CheckButton,
                    -- ScrollFrame, or any frame with EnableMouse explicitly set).
                    -- This avoids accidentally enabling mouse events on decorative frames.
                    local mouseEnabled = (ot == "Button" or ot == "CheckButton"
                        or ot == "ScrollFrame")
                        or (child.IsMouseEnabled and child:IsMouseEnabled() == true)

                    if mouseEnabled then
                        HookInfoPanelTrigger(child, contentFrame, label)
                    end

                    -- Recurse regardless of mouse state to find enabled descendants
                    ScanInfoPanelChildren(child, contentFrame, label, depth + 1)
                end
            end
        end
    end
end

-- ---- AlliedRacesFrame setup ----
--
-- Diagnostic findings (WoW 12.0.1):
--   • AlliedRacesFrame does NOT exist at PLAYER_LOGIN — it is created lazily on
--     first open.  "Blizzard_AlliedRaces" is not a real addon so ADDON_LOADED
--     never fires for it.  A polling ticker (arfDiscTicker) retries until found.
--   • RaceInfoFrame.mouse = false and ScrollFrame.mouse = false — no mouse-enabled
--     ancestor exists to hook OnEnter/OnLeave conventionally.
--   • AlliedRacesFrame itself IS mouse-enabled, so its OnUpdate fires whenever
--     the window is visible.  rif:IsMouseOver() works even on a non-mouse-enabled
--     frame; we use it to detect hover without touching frame mouse state.

local arfHookDone   = false  -- true once we have attached to AlliedRacesFrame
local arfDiscTicker = nil    -- self-canceling discover ticker

-- Returns true when hooked (or already done), false when frame not yet available.
local function HookAlliedRacesFrame()
    if arfHookDone then return true end

    local arf = _G.AlliedRacesFrame
    if not arf then
        DebugLog("AlliedRaces: AlliedRacesFrame not found")
        return false
    end

    arfHookDone = true  -- set before any return so retries are skipped
    DebugLog("AlliedRaces: AlliedRacesFrame found, setting up hooks")

    local rif = arf.RaceInfoFrame
    if not rif then
        DebugLog("AlliedRaces: RaceInfoFrame (.RaceInfoFrame field) not found — skipping")
        return true
    end
    DebugLog("AlliedRaces: RaceInfoFrame =", FrameName(rif) or tostring(rif),
        "| strategy: rif:IsMouseOver() poll via AlliedRacesFrame.OnUpdate")

    local st = GetIPState(rif)
    local arfPollThrottle = 0
    local ARF_POLL_INTERVAL = 0.1   -- check 10× per second; negligible CPU

    -- Throttled OnUpdate on AlliedRacesFrame (mouse-enabled).
    -- rif:IsMouseOver() works on non-mouse-enabled frames — it checks screen bounds.
    TryHookScript(arf, "OnUpdate", function()
        if not UiTTSDB or not UiTTSDB.readInfoPanels then return end

        local now = GetTime()
        if (now - arfPollThrottle) < ARF_POLL_INTERVAL then return end
        arfPollThrottle = now

        local over = rif.IsMouseOver and rif:IsMouseOver()

        if over and not st.hovering then
            -- Transition: outside → inside RaceInfoFrame
            st.hovering = true
            DebugLog("AlliedRaces: mouse entered RaceInfoFrame")

            if C_Timer and C_Timer.After then
                C_Timer.After(IP_ENTER_DELAY, function()
                    -- Re-verify after defer: mouse may have left already
                    if not (rif.IsMouseOver and rif:IsMouseOver()) then
                        st.hovering = false
                        DebugLog("AlliedRaces: mouse left before read — cancelled")
                        return
                    end
                    if not UiTTSDB or not UiTTSDB.readInfoPanels then return end
                    local text = BuildInfoPanelText(rif)
                    if not text then
                        DebugLog("AlliedRaces: no text extracted from RaceInfoFrame")
                        return
                    end
                    DebugLog("AlliedRaces: speaking text =", text:sub(1, 120))
                    SpeakInfoPanel(text)
                end)
            else
                local text = BuildInfoPanelText(rif)
                if text then
                    DebugLog("AlliedRaces: speaking text =", text:sub(1, 120))
                    SpeakInfoPanel(text)
                end
            end

        elseif not over and st.hovering then
            -- Transition: inside → outside RaceInfoFrame
            st.hovering = false
            ipLastSpeakTxt = nil   -- allow re-read on next hover
            DebugLog("AlliedRaces: mouse left RaceInfoFrame — hover state cleared")
        end
    end)

    -- Reset hover state whenever the Allied Races window is freshly shown
    TryHookScript(arf, "OnShow", function()
        local st2 = GetIPState(rif)
        st2.hovering = false
        ipLastSpeakTxt = nil
        DebugLog("AlliedRaces: OnShow — hover state reset")
    end)

    DebugLog("AlliedRaces: hook setup complete")
    return true
end

-- Start a self-canceling ticker that polls for AlliedRacesFrame until found.
-- Does an immediate attempt first; if that fails, falls back to a 1.5s ticker.
-- Idempotent: subsequent calls are no-ops once the ticker is running or done.
local function StartAlliedRacesDiscover()
    if arfHookDone then return end   -- already hooked

    -- Immediate attempt
    if HookAlliedRacesFrame() then return end
    if NS and NS.IsAddonAvailable and not NS.IsAddonAvailable("Blizzard_AlliedRacesUI") then return end

    -- Frame not available yet — start polling
    if arfDiscTicker then return end   -- ticker already running
    if not (C_Timer and C_Timer.NewTicker) then return end

    arfDiscTicker = C_Timer.NewTicker(1.5, function()
        if HookAlliedRacesFrame() then
            pcall(function() arfDiscTicker:Cancel() end)
            arfDiscTicker = nil
            DebugLog("AlliedRaces: discover ticker stopped (hooked)")
        end
    end)
    DebugLog("AlliedRaces: discover ticker started (polling every 1.5 s)")
end

-- ========= Shop / Store UI Reader =========
--
-- Reads visible text from the Blizzard in-game shop (StoreFrame) when the
-- mouse enters a product card, and reads button labels on hover.
-- Gated by UiTTSDB.readShopUI.
--
-- Two reading modes:
--   Card reading  — IsMouseOver() polling (via StoreFrame.OnUpdate, throttled)
--                   on registered product-card frames.  Works even if card frames
--                   have mouse = false; IsMouseOver() is a bounds check only.
--   Button reading — OnEnter hooks on Button descendants; label suppressed when
--                    it was already included in the last card read.
--
-- Dedup: isolated shopLastSpeakTxt / shopLastSpeakAt; does not interfere with
-- tooltip, GameMenu, EventToast, PlayerChoice, or other UIReader features.
--
-- Discovery: tries known store-frame global names at login; watches ADDON_LOADED
-- for Blizzard_Store / Blizzard_StoreUI; falls back to a 2 s polling ticker.
-- Rescans for product cards on OnShow and every SHOP_RESCAN_INTERVAL seconds
-- while the store is open, to handle tab changes and pooled / dynamic cards.

local SHOP_POLL_INTERVAL   = 0.12   -- IsMouseOver check rate while store is open (s)
local SHOP_ENTER_DELAY     = 0.15   -- defer card text read after mouse enters card (s)
local SHOP_BTN_DELAY       = 0.10   -- defer button label read after OnEnter (s)
local SHOP_RESCAN_INTERVAL = 3.0    -- periodic product-list rescan while store open (s)

local shopHookDone   = false
local shopDiscTicker = nil
local shopPollTicker = nil   -- C_Timer.NewTicker fallback when proxy hook unavailable

-- Isolated speak state
local shopLastSpeakTxt = nil
local shopLastSpeakAt  = 0

local function SpeakShopUI(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end
    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if UiTTSDB.skipSameText and text == shopLastSpeakTxt
        and (now - shopLastSpeakAt) < 2.0 then
        DebugLog("Shop: dedup — skipped identical text")
        return
    end
    if (now - shopLastSpeakAt) < minInterval then
        DebugLog("Shop: minInterval — skipped")
        return
    end
    shopLastSpeakTxt = text
    shopLastSpeakAt  = now
    DebugLog("[Shop]", text:sub(1, 120))
    Speak(text)
end

-- Extract readable text from a product card / panel frame subtree.
local function BuildShopCardText(cardFrame)
    if not cardFrame then return nil end
    if cardFrame.IsForbidden then
        local ok, v = pcall(cardFrame.IsForbidden, cardFrame)
        if ok and v then return nil end
    end
    return BuildSortedText(cardFrame)
end

-- Per-card IsMouseOver hover state, keyed by card frame object.
local shopCardState = {}

local function GetShopCardSt(cardFrame)
    local st = shopCardState[cardFrame]
    if not st then
        st = { hovering = false, lastText = nil }
        shopCardState[cardFrame] = st
    end
    return st
end

-- Registered card frames: list of { cardFrame, readFrom }.
-- readFrom is the frame whose subtree is collected (usually the same as cardFrame).
local shopRegisteredCards = {}

local function RegisterShopCard(cardFrame, readFrom)
    for _, entry in ipairs(shopRegisteredCards) do
        if entry[1] == cardFrame then return end
    end
    shopRegisteredCards[#shopRegisteredCards + 1] = { cardFrame, readFrom or cardFrame }
    DebugLog("Shop: registered card", FrameName(cardFrame) or tostring(cardFrame))
end

-- Poll a single card frame for mouse-over transitions.
local function PollShopCard(cardFrame, readFrom)
    if not cardFrame then return end
    if cardFrame.IsForbidden then
        local ok, v = pcall(cardFrame.IsForbidden, cardFrame)
        if ok and v then return end
    end

    -- If the card is not visible (scrolled off, hidden), clear hover state silently
    if cardFrame.IsVisible then
        local ok, v = pcall(cardFrame.IsVisible, cardFrame)
        if ok and not v then
            local st = shopCardState[cardFrame]
            if st then st.hovering = false end
            return
        end
    end

    local over = false
    if cardFrame.IsMouseOver then
        local ok, v = pcall(cardFrame.IsMouseOver, cardFrame)
        if ok then over = v end
    end
    local st = GetShopCardSt(cardFrame)

    if over and not st.hovering then
        -- Transition: outside → inside card bounds
        st.hovering = true
        DebugLog("Shop: mouse entered card", FrameName(cardFrame) or tostring(cardFrame))

        if C_Timer and C_Timer.After then
            C_Timer.After(SHOP_ENTER_DELAY, function()
                local st2 = shopCardState[cardFrame]
                if not st2 or not st2.hovering then return end
                if not UiTTSDB or not UiTTSDB.readShopUI then return end
                -- Re-verify after delay; mouse may have moved away
                local stillOver = false
                if cardFrame.IsMouseOver then
                    local ok, v = pcall(cardFrame.IsMouseOver, cardFrame)
                    if ok then stillOver = v end
                end
                if not stillOver then
                    st2.hovering = false
                    DebugLog("Shop: mouse left card before read — cancelled")
                    return
                end
                local text = BuildShopCardText(readFrom or cardFrame)
                if not text then
                    DebugLog("Shop: no text found in card",
                        FrameName(cardFrame) or tostring(cardFrame))
                    return
                end
                -- Re-read if card text changed (pooled frame now showing different product)
                if UiTTSDB.skipSameText and text == st2.lastText then
                    DebugLog("Shop: card text unchanged — skipped")
                    return
                end
                st2.lastText = text
                DebugLog("Shop: card text =", text:sub(1, 120))
                SpeakShopUI(text)
            end)
        else
            local text = BuildShopCardText(readFrom or cardFrame)
            if text then
                GetShopCardSt(cardFrame).lastText = text
                DebugLog("Shop: card text =", text:sub(1, 120))
                SpeakShopUI(text)
            end
        end

    elseif not over and st.hovering then
        -- Transition: inside → outside card bounds
        st.hovering = false
        DebugLog("Shop: mouse left card", FrameName(cardFrame) or tostring(cardFrame))
    end
end

-- Button hooks: keyed by button frame to prevent double-hooking.
local hookedShopButtons = {}

local function HookShopButton(btn, ctxLabel)
    if not btn or hookedShopButtons[btn] then return end
    -- Only hook frames that are already mouse-interactive; never enable mouse
    -- on a frame that Blizzard left non-interactive (would intercept clicks).
    local ot
    if btn.GetObjectType then
        local ok, v = pcall(btn.GetObjectType, btn)
        if ok then ot = v end
    end
    if ot ~= "Button" and ot ~= "CheckButton" then
        local mouseEnabled = false
        if btn.IsMouseEnabled then
            local ok, v = pcall(btn.IsMouseEnabled, btn)
            if ok then mouseEnabled = (v == true) end
        end
        if not mouseEnabled then
            DebugLog("Shop: skip non-mouse-enabled frame for button hook:",
                FrameName(btn) or tostring(btn))
            return
        end
    end
    hookedShopButtons[btn] = true

    TryHookScript(btn, "OnEnter", function(self)
        if not UiTTSDB or not UiTTSDB.readShopUI then return end
        local label = GetButtonLabel(self)
        if not label then return end
        DebugLog("Shop button [" .. (ctxLabel or "?") .. "]:", label)

        if C_Timer and C_Timer.After then
            C_Timer.After(SHOP_BTN_DELAY, function()
                if not UiTTSDB or not UiTTSDB.readShopUI then return end
                -- If the button label is already part of the last spoken card text,
                -- skip it — CollectFrameText already captured it from the card subtree.
                if UiTTSDB.skipSameText and shopLastSpeakTxt
                    and shopLastSpeakTxt:find(label, 1, true) then
                    DebugLog("Shop button: label already in last card read — skipped")
                    return
                end
                SpeakShopUI(label)
            end)
        else
            SpeakShopUI(label)
        end
    end)

    DebugLog("Shop: hooked button", FrameName(btn) or tostring(btn),
        "ctx:", ctxLabel or "?")
end

-- Tail segments (last dot-separated name segment) that indicate decorative frames
-- which should never be hooked or registered as cards.
local SHOP_SKIP_TAILS = {
    Model = true, ModelScene = true, Background = true, Backdrop = true,
    Artwork = true, NineSlice = true, Shadow = true, Glow = true,
    Flash = true, BG = true, Bg = true, Border = true,
    TitleBackground = true, ButtonBackground = true, PortraitFrame = true,
}

local function IsShopSkipFrame(child)
    if not child then return true end
    local ot
    if child.GetObjectType then
        local ok, v = pcall(child.GetObjectType, child)
        if ok then ot = v end
    end
    if ot == "Model" or ot == "PlayerModel" or ot == "CinematicModel"
        or ot == "DressUpModel" or ot == "TabardModel" then
        return true
    end
    local name = FrameName(child)
    if name then
        local tail = name:match("[^%.]+$") or name
        if SHOP_SKIP_TAILS[tail] then return true end
        if tail:find("Model", 1, true) then return true end
        if tail:find("ModelScene") then return true end
    end
    return false
end

-- Scan a frame subtree for:
--   • Button / CheckButton frames → hook for label reading
--   • If isProductArea=true, direct children of parent → register as card candidates
-- Bounded by SHOP_SCAN_DEPTH to avoid runaway recursion.
local SHOP_SCAN_DEPTH = 6

local function ScanShopFrame(parent, depth, isProductArea)
    if not parent or depth > SHOP_SCAN_DEPTH then return end
    if parent.IsForbidden then
        local ok, v = pcall(parent.IsForbidden, parent)
        if ok and v then return end
    end

    local ok, kids = pcall(function() return { parent:GetChildren() } end)
    if not ok or not kids then return end

    for _, child in ipairs(kids) do
        if child and not IsShopSkipFrame(child) then
            local ot
            if child.GetObjectType then
                local ok, v = pcall(child.GetObjectType, child)
                if ok then ot = v end
            end

            -- Hook any button inside the store for label reading
            if ot == "Button" or ot == "CheckButton" then
                local ctxName = FrameName(child)
                local ctx = ctxName and (ctxName:match("[^%.]+$") or ctxName) or "btn"
                HookShopButton(child, ctx)
            end

            -- Register direct children of the product-list area as card candidates
            if isProductArea and not child.__UiTTSShopCardReg then
                child.__UiTTSShopCardReg = true
                RegisterShopCard(child, child)
                -- Recurse into card children for nested buttons, but NOT as product area
                ScanShopFrame(child, depth + 1, false)
            elseif not isProductArea then
                ScanShopFrame(child, depth + 1, false)
            end
        end
    end
end

-- Walk the store frame's subtree to find the first ScrollFrame and return its
-- scroll child (where product tiles live).  Returns nil if none found.
local function FindProductListFrame(storeFrame)
    if not storeFrame then return nil end
    local found = nil

    local function walk(f, d)
        if found or not f or d > 5 then return end
        if f.IsForbidden then
            local ok, v = pcall(f.IsForbidden, f)
            if ok and v then return end
        end
        local ok, kids = pcall(function() return { f:GetChildren() } end)
        if not ok or not kids then return end
        for _, child in ipairs(kids) do
            if child then
                local ot
                if child.GetObjectType then
                    local cok, cv = pcall(child.GetObjectType, child)
                    if cok then ot = cv end
                end
                if ot == "ScrollFrame" then
                    local sfKids
                    pcall(function() sfKids = { child:GetChildren() } end)
                    if sfKids and #sfKids >= 1 and sfKids[1] then
                        found = sfKids[1]
                        DebugLog("Shop: ScrollFrame found; scroll child =",
                            FrameName(found) or tostring(found))
                        return
                    end
                end
                if not found then walk(child, d + 1) end
            end
        end
    end

    walk(storeFrame, 0)
    return found
end

-- Throttle variable shared by RescanShopProducts to prevent back-to-back calls
-- (e.g. the two OnShow timer passes at 0.3 s and 1.2 s).
local shopLastRescanAt = 0

-- Walk a WoW PoolCollectionMixin (productCardPoolCollection) and call cb(frame)
-- for every active frame in every pool.  Silently ignores any pool that doesn't
-- support the expected interface.
local function IteratePoolCollection(poolCollection, cb)
    if not poolCollection then return end
    -- PoolCollectionMixin stores pools in self.poolsByType (table of pools) or
    -- exposes :EnumerateActive() directly.  Try both patterns.
    if poolCollection.EnumerateActive then
        local ok = pcall(poolCollection.EnumerateActive, poolCollection,
            function(frame) cb(frame) end)
        if ok then return end
    end
    -- Fallback: iterate poolsByType table of individual PoolMixins
    if type(poolCollection.poolsByType) == "table" then
        for _, pool in pairs(poolCollection.poolsByType) do
            if pool and pool.EnumerateActive then
                pcall(pool.EnumerateActive, pool, function(frame) cb(frame) end)
            elseif pool and type(pool.activeObjects) == "table" then
                for frame in pairs(pool.activeObjects) do cb(frame) end
            end
        end
    end
    -- Last resort: the collection itself might be a flat table of active frames
    if type(poolCollection.activeObjects) == "table" then
        for frame in pairs(poolCollection.activeObjects) do cb(frame) end
    end
end

local function RescanShopProducts(storeFrame)
    if not storeFrame then return end
    local now = GetTime()
    if (now - shopLastRescanAt) < 0.5 then return end
    shopLastRescanAt = now

    DebugLog("Shop: rescanning product frames")

    -- Strategy 1: productCardPoolCollection — preferred for the Mixin StoreFrame.
    -- storeFrame.productCardPoolCollection is a table confirmed in the dump.
    local poolCollection = storeFrame.productCardPoolCollection
    if poolCollection then
        local count = 0
        shopRegisteredCards = {}
        shopCardState = {}
        IteratePoolCollection(poolCollection, function(cardFrame)
            if cardFrame and not cardFrame.__UiTTSShopCardReg then
                cardFrame.__UiTTSShopCardReg = true
                RegisterShopCard(cardFrame, cardFrame)
                ScanShopFrame(cardFrame, 0, false)
                count = count + 1
            end
        end)
        if count > 0 then
            DebugLog("Shop: pool strategy found", count, "card(s)")
            DebugLog("Shop: registered", #shopRegisteredCards, "card frame(s)")
            return
        end
        DebugLog("Shop: pool strategy found 0 cards — falling back to ScrollFrame scan")
    end

    -- Strategy 2: walk the visual tree from a known real C-frame child.
    -- Use storeFrame.RightDisplay if available (confirmed C Frame), otherwise storeFrame itself.
    local scanRoot = storeFrame.RightDisplay or storeFrame
    local productList = FindProductListFrame(scanRoot)
    if productList then
        DebugLog("Shop: product list =", FrameName(productList) or tostring(productList))
        shopRegisteredCards = {}
        shopCardState = {}
        local ok, kids = pcall(function() return { productList:GetChildren() } end)
        if ok and kids then
            for _, c in ipairs(kids) do
                if c then c.__UiTTSShopCardReg = nil end
            end
        end
        ScanShopFrame(productList, 0, true)
    else
        DebugLog("Shop: no ScrollFrame/product-list found; scanning store for buttons only")
        ScanShopFrame(scanRoot, 0, false)
    end

    DebugLog("Shop: registered", #shopRegisteredCards, "card frame(s)")
end

-- Known global names for the store frame (tried in order at discovery time).
local STORE_FRAME_NAMES = { "StoreFrame", "Blizzard_StoreFrame", "BlizzardStoreFrame" }

local function HookStoreFrame()
    if shopHookDone then return true end

    local storeFrame = nil
    for _, n in ipairs(STORE_FRAME_NAMES) do
        if _G[n] then
            storeFrame = _G[n]
            DebugLog("Shop: found store frame:", n,
                "| name:", FrameName(storeFrame) or tostring(storeFrame))
            break
        end
    end

    if not storeFrame then
        DebugLog("Shop: no store frame found yet")
        return false
    end

    shopHookDone = true

    -- storeFrame in WoW 12.x is a Mixin Lua table — C frame methods like
    -- :HookScript() / :HasScript() / :IsShown() cannot be called on it directly.
    -- Use storeFrame.RightDisplay (confirmed real C Frame) as the hook proxy.
    local proxyFrame = storeFrame.RightDisplay

    -- Throttled OnUpdate closure (shared by proxy hook and ticker fallback).
    local pollThrottle   = 0
    local rescanThrottle = 0

    local function OnUpdateHandler()
        if not UiTTSDB or not UiTTSDB.readShopUI then return end
        local now = GetTime()
        if (now - pollThrottle) >= SHOP_POLL_INTERVAL then
            pollThrottle = now
            for _, entry in ipairs(shopRegisteredCards) do
                PollShopCard(entry[1], entry[2])
            end
        end
        if (now - rescanThrottle) >= SHOP_RESCAN_INTERVAL then
            rescanThrottle = now
            RescanShopProducts(storeFrame)
        end
    end

    local function OnShowHandler()
        DebugLog("Shop: OnShow — resetting state and rescanning")
        shopRegisteredCards = {}
        shopCardState = {}
        shopLastSpeakTxt = nil
        shopLastRescanAt = 0
        if C_Timer and C_Timer.After then
            C_Timer.After(0.3,  function() RescanShopProducts(storeFrame) end)
            C_Timer.After(1.2,  function() RescanShopProducts(storeFrame) end)
        else
            RescanShopProducts(storeFrame)
        end
    end

    local proxyHooked = false
    if proxyFrame then
        -- Hook via the real C-frame child so we get per-frame OnUpdate/OnShow.
        local okU = pcall(function() proxyFrame:HookScript("OnUpdate", OnUpdateHandler) end)
        local okS = pcall(function() proxyFrame:HookScript("OnShow",   OnShowHandler) end)
        proxyHooked = okU and okS
        if proxyHooked then
            DebugLog("Shop: hooked OnUpdate/OnShow via RightDisplay proxy")
        else
            DebugLog("Shop: proxy HookScript failed — falling back to C_Timer.NewTicker")
        end
    else
        DebugLog("Shop: RightDisplay not found — using C_Timer.NewTicker fallback")
    end

    if not proxyHooked then
        -- Fallback: drive the poll loop via a repeating ticker.
        if C_Timer and C_Timer.NewTicker and not shopPollTicker then
            shopPollTicker = C_Timer.NewTicker(SHOP_POLL_INTERVAL, function()
                OnUpdateHandler()
            end)
            DebugLog("Shop: poll ticker started (interval:", SHOP_POLL_INTERVAL, "s)")
        end
        -- Drive periodic rescan via a slower ticker.
        if C_Timer and C_Timer.NewTicker then
            C_Timer.NewTicker(SHOP_RESCAN_INTERVAL, function()
                RescanShopProducts(storeFrame)
            end)
        end
        -- Hook OnShow via any known real button child as a proxy.
        local showProxy = storeFrame.CloseButton or storeFrame.BuyButton
        if showProxy then
            -- Use OnHide of the close button as a rough OnShow signal instead.
            -- Better: hook a named Frame child if visible.
            pcall(function()
                showProxy:HookScript("OnShow", OnShowHandler)
            end)
        end
    end

    -- Directly hook known top-level button children on the Mixin table.
    -- These are confirmed real C Button frames from the dump.
    local directButtons = {
        { storeFrame.BuyButton,      "BuyButton" },
        { storeFrame.PrevPageButton, "PrevPageButton" },
        { storeFrame.NextPageButton, "NextPageButton" },
        { storeFrame.CloseButton,    "CloseButton" },
    }
    for _, pair in ipairs(directButtons) do
        local btn, ctx = pair[1], pair[2]
        if btn then
            HookShopButton(btn, ctx)
        end
    end

    -- Initial scan: try immediately (pool may already be populated).
    RescanShopProducts(storeFrame)

    DebugLog("Shop: hook setup complete")
    return true
end

-- Start a self-canceling polling ticker that retries until the store frame appears.
-- Idempotent: no-op if already running or already hooked.
local function StartShopDiscover()
    if shopHookDone then return end
    if HookStoreFrame() then return end    -- immediate attempt
    if NS and NS.IsAddonAvailable and not NS.IsAddonAvailable("Blizzard_StoreUI",
        "Blizzard_Store", "Blizzard_PremiumStore") then return end
    if shopDiscTicker then return end       -- ticker already running
    if not (C_Timer and C_Timer.NewTicker) then
        return   -- no timer API; give up (HookStoreFrame already tried)
    end
    shopDiscTicker = C_Timer.NewTicker(2.0, function()
        if HookStoreFrame() then
            pcall(function() shopDiscTicker:Cancel() end)
            shopDiscTicker = nil
            DebugLog("Shop: discover ticker stopped (hooked)")
        end
    end)
    DebugLog("Shop: discover ticker started (polling every 2.0 s)")
end

-- ========= Catalog Shop reader (Blizzard_CatalogShop / CatalogShopFrame) =========
--
-- Retail 12.x replaced Blizzard_Store's StoreFrame with Blizzard_CatalogShop's
-- CatalogShopFrame (an /fstack over the shop window reports
-- CatalogShopFrame.ProductDetailsContainerFrame.DetailsProductContainerFrame.
-- ProductsHeader.ProductDescription, sourced from
-- Interface/AddOns/Blizzard_CatalogShop/Blizzard_CatalogShop_Elements.xml).
-- The StoreFrame reader above finds no frame at all on such a client, which is
-- why nothing in the shop was spoken.
--
-- The internals are not stable enough to hard-code: product cards live in a
-- ScrollBox (object type Frame, so FindProductListFrame's ScrollFrame search
-- misses them) and every row is pooled and reused.  This therefore mirrors the
-- gossip-option hover reader — hook OnEnter on every mouse-enabled descendant,
-- reject frames that take up a large fraction of the window (the containers are
-- mouse-enabled too, so hovering the gaps would read the whole page), and
-- rescan while the window is open.  The product details page is additionally
-- read in full when it opens, because it is reached by click, not by hover.
--
-- Everything lives in one table on purpose: this file is close to Lua's 200
-- locals-per-chunk limit, and a module table costs a single local.
local catShop = {
    NAMES        = { "CatalogShopFrame", "CatalogShopProductDetailsFrame" },
    DEPTH        = 8,      -- how deep to walk below CatalogShopFrame
    MAX_LINES    = 6,      -- one card / row
    DETAIL_LINES = 14,     -- the details page is title + type + a paragraph
    INTERVAL     = 0.5,    -- rescan period while the window is open
    POLL         = 0.30,   -- details-page change poll (s)
    RETRIES      = 6,      -- details text arrives a few frames after the show
    RETRY_DELAY  = 0.15,
    frame        = nil,
    ticker       = nil,
    discTicker   = nil,
    pollAt       = 0,
    detailText   = nil,    -- last details-page text spoken (change detection)
    detailSerial = 0,      -- drops superseded retry chains
    lastText     = nil,    -- isolated dedup state (never touches other readers)
    lastAt       = 0,
}

-- Returns the shop window only while it is on screen, so every entry point can
-- cheaply no-op when the shop is closed.
function catShop.Root()
    local f = catShop.frame
    if not f then
        for _, n in ipairs(catShop.NAMES) do
            if _G[n] then f = _G[n]; break end
        end
    end
    if not f then return nil end
    if f.IsShown then
        local ok, shown = pcall(f.IsShown, f)
        if ok and not shown then return nil end
    end
    return f
end

function catShop.Speak(text, why)
    if not text or text == "" then return end
    local now = GetTime()
    if UiTTSDB.skipSameText and text == catShop.lastText and (now - catShop.lastAt) < 3.0 then
        return
    end
    if (now - catShop.lastAt) < (tonumber(UiTTSDB.minInterval) or 0) then return end
    catShop.lastText = text
    catShop.lastAt   = now
    DebugLog("[CatalogShop " .. (why or "?") .. "]", text:sub(1, 120))
    Speak(text)
end

function catShop.OnEnter(self)
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readShopUI) then return end

    local root = catShop.Root()
    if not root then return end

    -- Containers (the page frame, the ScrollBox) are mouse-enabled as well;
    -- a card is only a fraction of the window's height.
    local okG, wh = pcall(root.GetHeight, root)
    local function TooBig(frame)
        if not (okG and wh and wh > 0) then return false end
        local okH, h = pcall(frame.GetHeight, frame)
        return okH and h and h > wh * 0.5
    end
    if TooBig(self) then return end

    local text = BuildSortedText(self, catShop.MAX_LINES)
    if not text then
        -- Some rows put the mouse-enabled hit area on a bare child frame with
        -- no FontStrings of its own; the label then lives on the parent row.
        local okP, parent = pcall(function() return self:GetParent() end)
        if okP and parent and parent ~= root and not TooBig(parent) then
            text = BuildSortedText(parent, catShop.MAX_LINES)
        end
    end
    if not text then return end

    -- The details page was just read in full; hovering its header would only
    -- repeat a slice of what is still being spoken.
    if catShop.lastText and catShop.lastText:find(text, 1, true)
        and (GetTime() - catShop.lastAt) < 3.0 then
        return
    end

    catShop.Speak(text, "hover")
end

-- Treats an errored IsForbidden() as forbidden: the shop's ScrollBoxListView
-- rows are protected hard enough that even this call raises, and a frame that
-- refuses to answer cannot be hooked or read anyway.
function catShop.Forbidden(frame)
    if not frame or not frame.IsForbidden then return false end
    local ok, forbidden = pcall(frame.IsForbidden, frame)
    if not ok then return true end
    return forbidden and true or false
end

-- Hooks OnEnter on every mouse-enabled descendant not hooked yet.
-- Returns how many were newly hooked.
function catShop.HookTree(frame, depth)
    if not frame or depth > catShop.DEPTH then return 0 end
    if catShop.Forbidden(frame) then return 0 end

    local ok, kids = pcall(function() return { frame:GetChildren() } end)
    if not ok or not kids then return 0 end

    local count = 0
    for _, child in ipairs(kids) do
        if child and not catShop.Forbidden(child)
            and not IsShopSkipFrame(child) then
            -- IsPCFrameMouseEnabled is generic despite the name: Button /
            -- CheckButton by type, or any frame with EnableMouse(true).
            if not child.__UiTTSCatShopHooked and IsPCFrameMouseEnabled(child) then
                child.__UiTTSCatShopHooked = true
                TryHookScript(child, "OnEnter", catShop.OnEnter)
                count = count + 1
            end
            count = count + catShop.HookTree(child, depth + 1)
        end
    end
    return count
end

-- The details container as it appears in the frame stack, with the inner
-- DetailsProductContainerFrame preferred so the read excludes page chrome.
-- Returns nil while the product list (rather than a product) is showing.
function catShop.DetailsFrame(root)
    if not root then return nil end

    local d = root.ProductDetailsContainerFrame
    if not d then
        -- parentKey renamed by a patch: fall back to whichever direct child
        -- carries the details page's own sub-frames.
        local ok, kids = pcall(function() return { root:GetChildren() } end)
        if ok and kids then
            for _, c in ipairs(kids) do
                if c and (c.DetailsProductContainerFrame or c.ProductsHeader) then
                    d = c
                    break
                end
            end
        end
    end
    if not d then return nil end

    if d.IsShown then
        local ok, shown = pcall(d.IsShown, d)
        if ok and not shown then return nil end
    end

    local inner = d.DetailsProductContainerFrame
    if inner then d = inner end
    return d
end

-- Reads the whole product details page.  Driven by a poll rather than OnShow:
-- picking another product swaps the page contents in place, so OnShow fires
-- only for the first product opened in a session.
function catShop.PollDetails()
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readShopUI) then return end

    local root = catShop.Root()
    if not root then return end

    local d = catShop.DetailsFrame(root)
    if not d then
        catShop.detailText = nil   -- back on the product list; re-arm the read
        return
    end

    local text = BuildSortedText(d, catShop.DETAIL_LINES)
    if not text or text == catShop.detailText then return end

    catShop.detailText = text
    catShop.Speak(text, "details")
end

function catShop.Scan()
    if not (UiTTSDB and UiTTSDB.readShopUI) then return end
    local root = catShop.Root()
    if not root then return end
    local n = catShop.HookTree(root, 1)
    if n > 0 then
        DebugLog("CatalogShop: hooked", n, "frame(s) for hover reading")
    end
end

-- Retries because the ScrollBox fills its rows a few frames after the window
-- shows; a serial token drops a superseded chain when the page changes again.
function catShop.ReadOnShow()
    catShop.detailSerial = catShop.detailSerial + 1
    local serial = catShop.detailSerial
    catShop.detailText = nil

    local function attempt(n)
        if serial ~= catShop.detailSerial then return end
        catShop.Scan()
        catShop.PollDetails()
        if catShop.detailText == nil and n < catShop.RETRIES
            and C_Timer and C_Timer.After then
            C_Timer.After(catShop.RETRY_DELAY, function() attempt(n + 1) end)
        end
    end
    attempt(1)
end

function catShop.Hook()
    if catShop.frame then return true end

    local f
    for _, n in ipairs(catShop.NAMES) do
        if _G[n] then f = _G[n]; break end
    end
    if not f then return false end

    catShop.frame = f
    DebugLog("CatalogShop: found", FrameName(f) or tostring(f))

    TryHookScript(f, "OnShow", function()
        DebugLog("CatalogShop: OnShow")
        catShop.lastText   = nil
        catShop.detailText = nil
        if C_Timer and C_Timer.After then
            C_Timer.After(0.05, catShop.ReadOnShow)
            C_Timer.After(0.40, catShop.ReadOnShow)
        else
            catShop.ReadOnShow()
        end
    end)

    TryHookScript(f, "OnHide", function()
        catShop.detailSerial = catShop.detailSerial + 1
        catShop.lastText   = nil
        catShop.detailText = nil
    end)

    -- One ticker drives both the rescan (pooled rows appear after the window is
    -- already visible) and the details-page change poll.  It no-ops while the
    -- shop is closed, so it costs nothing outside the window.
    if not catShop.ticker and C_Timer and C_Timer.NewTicker then
        catShop.ticker = C_Timer.NewTicker(catShop.INTERVAL, function()
            if not (UiTTSDB and UiTTSDB.readShopUI) then return end
            if not catShop.Root() then return end
            catShop.Scan()
            local now = GetTime()
            if (now - catShop.pollAt) >= catShop.POLL then
                catShop.pollAt = now
                catShop.PollDetails()
            end
        end)
    end

    catShop.Scan()
    return true
end

-- Retries until CatalogShopFrame exists: Blizzard_CatalogShop is load-on-demand,
-- so the frame is absent at PLAYER_LOGIN and only appears once the shop is
-- opened for the first time.
function catShop.Start()
    if catShop.Hook() then return end
    if NS and NS.IsAddonAvailable and not NS.IsAddonAvailable("Blizzard_CatalogShop") then return end
    if catShop.discTicker then return end
    if not (C_Timer and C_Timer.NewTicker) then return end
    catShop.discTicker = C_Timer.NewTicker(2.0, function()
        if catShop.Hook() then
            pcall(function() catShop.discTicker:Cancel() end)
            catShop.discTicker = nil
            DebugLog("CatalogShop: discover ticker stopped (hooked)")
        end
    end)
    DebugLog("CatalogShop: discover ticker started")
end

-- ========= DialogueUI option-button reader =========
--
-- DialogueUI replaces the Blizzard gossip / quest dialog with a custom panel.
-- Each gossip choice, accept and exit button is built from
-- DUIDialogOptionButtonTemplate and gets DUIDialogOptionButtonMixin.  Hovering
-- such a button does NOT show a tooltip (unless the gossip carries an extra
-- hint), so the only way to read the visible label aloud is to hook OnEnter on
-- the button itself.
--
-- Detection signature: any Button frame whose table exposes both SetGossip and
-- SetGossipHint.  Those Mixin methods are unique to DUI's option button and are
-- copied onto every instance when API.Mixin runs at template OnLoad.

-- Ordered cheapest-test-first on purpose.  This runs once per frame in the
-- whole UI (tens of thousands of objects), so the two Mixin-method lookups --
-- plain table reads that reject virtually every frame -- must come before the
-- IsForbidden / GetObjectType calls, which cross into C and cost orders of
-- magnitude more.  With the old order those C calls ran for every frame and
-- tripped WoW's "script ran too long" watchdog inside IsForbidden.
local function IsDUIDialogOptionButton(f)
    if not f then return false end
    if type(f.SetGossip) ~= "function" then return false end
    if type(f.SetGossipHint) ~= "function" then return false end
    if f.IsForbidden and f:IsForbidden() then return false end
    if not f.GetObjectType then return false end
    local ok, ot = pcall(f.GetObjectType, f)
    if not ok or ot ~= "Button" then return false end
    return true
end

local function OnDUIDialogOptionEnter(self)
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readDialogueUIOptions) then return end
    if not self or (self.IsForbidden and self:IsForbidden()) then return end
    if self.IsShown and not self:IsShown() then return end

    -- DUI's OnLoad assigns self.Name = self.Content.Name (the button label
    -- FontString).  Fall back to the generic GetButtonLabel walker if for some
    -- reason Name is missing (e.g. during early load before OnLoad ran).
    local text
    if self.Name and self.Name.GetText then
        text = CleanText(self.Name:GetText())
    end
    if not text then
        text = GetButtonLabel(self)
    end
    if not text then return end

    SpeakUILabel(text, "DUIOption")
end

local duiOptionDiscTicker = nil
local duiOptionHookCount  = 0
local duiScanBackoff      = 0   -- consecutive walks that hooked nothing new (0..5)
local duiScanSkip         = 0   -- ticker cycles left to skip before the next walk
local duiScanCursor       = nil -- resume point of an interrupted walk (nil = start over)
local duiScanFound        = 0   -- buttons hooked so far by the walk in progress
local duiScanResumeQueued = false

-- Even with the cheap-first ordering above, a single uninterrupted walk of the
-- whole frame tree can exceed WoW's per-script time limit on a heavily
-- addon-loaded UI.  The walk is therefore chunked: each pass runs for at most
-- DUI_SCAN_BUDGET_MS, stores the EnumerateFrames cursor and resumes shortly
-- after.  Frames are never destroyed in WoW, so a stored cursor stays valid.
local DUI_SCAN_BUDGET_MS    = 4.0
local DUI_SCAN_CLOCK_EVERY  = 250    -- frames between debugprofilestop() reads
local DUI_SCAN_RESUME_DELAY = 0.05   -- s before continuing an interrupted walk

-- `force` restarts the walk from the top and bypasses the backoff skip.  Used
-- when a scan is genuinely due (addon just loaded, discover routine started,
-- or a gossip / quest interaction just opened a dialogue) so newly-pooled
-- buttons hook immediately instead of waiting out the backoff.
local function ScanDUIDialogOptionButtons(force)
    if not (UiTTSDB and UiTTSDB.readDialogueUIOptions) then return end
    if type(EnumerateFrames) ~= "function" then return end

    if force then
        duiScanBackoff = 0
        duiScanSkip = 0
        duiScanCursor = nil
    elseif duiScanCursor == nil then
        -- Backoff: the option buttons are pooled once and reused, so after a
        -- few walks find nothing new we skip an increasing number of ticker
        -- cycles rather than walking the entire frame tree every 2 s forever.
        -- Only applies between walks; a partial walk always resumes.
        if duiScanSkip > 0 then
            duiScanSkip = duiScanSkip - 1
            return
        end
    end

    local f = duiScanCursor
    if f == nil then duiScanFound = 0 end

    local deadline = nil
    if type(debugprofilestop) == "function" then
        deadline = debugprofilestop() + DUI_SCAN_BUDGET_MS
    end

    local sinceClock = 0
    local exhausted = false
    while true do
        f = EnumerateFrames(f)
        if not f then
            exhausted = true
            break
        end

        if not f.__UiTTSDUIOptionHooked and IsDUIDialogOptionButton(f) then
            f.__UiTTSDUIOptionHooked = true
            TryHookScript(f, "OnEnter", OnDUIDialogOptionEnter)
            duiScanFound = duiScanFound + 1
        end

        if deadline then
            sinceClock = sinceClock + 1
            if sinceClock >= DUI_SCAN_CLOCK_EVERY then
                sinceClock = 0
                if debugprofilestop() >= deadline then break end
            end
        end
    end

    if not exhausted then
        -- Out of time budget: park the cursor and pick up where we left off.
        duiScanCursor = f
        if C_Timer and C_Timer.After and not duiScanResumeQueued then
            duiScanResumeQueued = true
            C_Timer.After(DUI_SCAN_RESUME_DELAY, function()
                duiScanResumeQueued = false
                ScanDUIDialogOptionButtons()
            end)
        end
        return
    end

    duiScanCursor = nil

    if duiScanFound > 0 then
        duiOptionHookCount = duiOptionHookCount + duiScanFound
        duiScanBackoff = 0
        duiScanSkip = 0
        DebugLog("DUI: hooked", duiScanFound, "option button(s) (total:", duiOptionHookCount, ")")
    else
        duiScanBackoff = math.min(duiScanBackoff + 1, 5)
        duiScanSkip = duiScanBackoff
    end
    duiScanFound = 0
end

local function StartDUIDialogOptionDiscover()
    if NS and NS.IsAddonAvailable and not NS.IsAddonAvailable("DialogueUI") then return end
    -- Scan once immediately, then poll for newly-pooled buttons every 2 s.
    -- DUI lazily acquires buttons from a pool when it needs to display N
    -- options, so we can't hook them all up-front.
    ScanDUIDialogOptionButtons(true)
    if duiOptionDiscTicker then return end
    if not (C_Timer and C_Timer.NewTicker) then return end
    -- Wrap in a closure: NewTicker passes the ticker handle as the first arg,
    -- which would otherwise be seen as `force` and defeat the backoff.
    duiOptionDiscTicker = C_Timer.NewTicker(2.0, function() ScanDUIDialogOptionButtons() end)
    DebugLog("DUI: option-button discover ticker started (polling every 2.0 s)")
end

-- ========= Blizzard QuestFrame reader =========
--
-- Reads the full visible content of the default Blizzard QuestFrame (the NPC
-- quest offer / progress / reward / greeting panels) when it opens or switches
-- sub-panel.  Gated by UiTTSDB.readQuestFrame.
--
-- Two user-facing controls re-read the panel from the start:
--   • A speaker icon anchored next to the QuestFrame close button.
--   • The "R" key while the QuestFrame is visible (chat edit box takes priority).
--
-- Isolated dedup (qfLastSpeakTxt / qfLastSpeakAt) keeps this feature from
-- suppressing other UIReader readers within the 2-second same-text window.
-- Restart actions bypass the dedup by clearing qfLastSpeakTxt before speaking.

local QF_READ_DELAY = 0.15   -- defer after OnShow so panel text finishes populating

local qfLastSpeakTxt = nil
local qfLastSpeakAt  = 0
local qfSpeakerBtn   = nil
local qfHookDone     = false
local qfDiscTicker   = nil

local function SpeakQuestFrame(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end
    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if UiTTSDB.skipSameText and text == qfLastSpeakTxt
        and (now - qfLastSpeakAt) < 2.0 then
        DebugLog("QuestFrame: isolated dedup — skipped identical text")
        return
    end
    if (now - qfLastSpeakAt) < minInterval then
        DebugLog("QuestFrame: minInterval — skipped")
        return
    end
    qfLastSpeakTxt = text
    qfLastSpeakAt  = now
    DebugLog("[QuestFrame]", text:sub(1, 120))
    Speak(text)
end

-- Returns the currently visible sub-panel, or QuestFrame itself as a fallback.
local function FindVisibleQuestPanel()
    local qf = _G.QuestFrame
    if not qf then return nil end
    local panels = {
        _G.QuestFrameDetailPanel,
        _G.QuestFrameProgressPanel,
        _G.QuestFrameRewardPanel,
        _G.QuestFrameGreetingPanel,
    }
    for _, p in ipairs(panels) do
        if p and p.IsShown and p:IsShown() then return p end
    end
    return qf
end

local function BuildQuestFrameText()
    local panel = FindVisibleQuestPanel()
    if not panel then return nil end
    return BuildSortedText(panel)
end

-- Read the quest frame and speak its text.
-- force=true bypasses dedup so the same text can be spoken again (restart action).
local function ReadQuestFrame(source, force)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readQuestFrame then return end

    local qf = _G.QuestFrame
    if not qf or (qf.IsShown and not qf:IsShown()) then return end

    local delay = force and 0 or QF_READ_DELAY

    local function doRead()
        if not qf:IsShown() then return end
        local text = BuildQuestFrameText()
        if not text then
            DebugLog("QuestFrame: no text extracted (source:", source or "?", ")")
            return
        end
        if force then
            -- Clear dedup and stop any in-flight speech so the reader starts fresh.
            qfLastSpeakTxt = nil
            StopSpeaking()
        end
        DebugLog("QuestFrame read [" .. (source or "?") .. "]:", text:sub(1, 120))
        SpeakQuestFrame(text)
    end

    if C_Timer and C_Timer.After and delay > 0 then
        C_Timer.After(delay, doRead)
    else
        doRead()
    end
end

local function CreateQuestFrameSpeakerButton()
    if qfSpeakerBtn then return end
    local qf = _G.QuestFrame
    if not qf then return end

    local btn = CreateFrame("Button", "UiTTSQuestFrameSpeakerButton", qf)
    btn:SetSize(22, 22)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel((qf:GetFrameLevel() or 0) + 10)

    local close = qf.CloseButton or _G.QuestFrameCloseButton
    if close then
        btn:SetPoint("RIGHT", close, "LEFT", -2, 0)
    else
        btn:SetPoint("TOPRIGHT", qf, "TOPRIGHT", -38, -14)
    end

    -- Prefer an atlas speaker icon (modern retail); fall back to a texture and
    -- a text label so the button is still discoverable if neither atlas exists.
    local iconApplied = false
    if btn.SetNormalAtlas then
        local ok = pcall(btn.SetNormalAtlas, btn, "voicechat-speaker-on")
        if ok then
            pcall(btn.SetHighlightAtlas, btn, "voicechat-speaker-on")
            iconApplied = true
        end
    end
    if not iconApplied then
        local okTex = pcall(function()
            btn:SetNormalTexture("Interface\\Common\\VoiceChat-Speaker")
            btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        end)
        if not okTex then
            local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            fs:SetAllPoints(btn)
            fs:SetText("TTS")
        end
    end

    btn:SetScript("OnClick", function()
        ReadQuestFrame("speaker button", true)
    end)

    btn:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("UiTTS")
            GameTooltip:AddLine((L and L["Read quest again (R)"]) or "Read quest again (R)", 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    qfSpeakerBtn = btn
    DebugLog("QuestFrame: speaker button created")
end

-- Returns true if a chat edit box currently has keyboard focus.
-- When true we must not consume keyboard input, otherwise typing would break.
local function IsChatInputActive()
    if ChatEdit_GetActiveWindow then
        local w = ChatEdit_GetActiveWindow()
        if w then return true end
    end
    return false
end

local function HookQuestFrame()
    if qfHookDone then return true end
    local qf = _G.QuestFrame
    if not qf then return false end
    qfHookDone = true

    DebugLog("QuestFrame: hooking")

    -- Hook each sub-panel's OnShow; they are the reliable signal for a read
    -- because QuestFrame:OnShow fires before the active panel's text populates.
    local panels = {
        { _G.QuestFrameDetailPanel,   "Detail"   },
        { _G.QuestFrameProgressPanel, "Progress" },
        { _G.QuestFrameRewardPanel,   "Reward"   },
        { _G.QuestFrameGreetingPanel, "Greeting" },
    }
    for _, pair in ipairs(panels) do
        local p, label = pair[1], pair[2]
        if p then
            TryHookScript(p, "OnShow", function()
                ReadQuestFrame(label, false)
            end)
        end
    end

    TryHookScript(qf, "OnHide", function()
        qfLastSpeakTxt = nil
    end)

    -- Keyboard listener for the "R" restart key while the frame is visible.
    -- SetPropagateKeyboardInput(true) by default so other keys (movement,
    -- chat opener, bindings) still work; only consume when we actually act.
    local ok = pcall(function() qf:EnableKeyboard(true) end)
    if ok then
        pcall(function() qf:SetPropagateKeyboardInput(true) end)
        TryHookScript(qf, "OnKeyDown", function(self, key)
            if IsChatInputActive() then
                pcall(self.SetPropagateKeyboardInput, self, true)
                return
            end
            if key == "R"
                and UiTTSDB and UiTTSDB.enabled and UiTTSDB.readQuestFrame
                and self:IsShown() then
                pcall(self.SetPropagateKeyboardInput, self, false)
                ReadQuestFrame("R key", true)
            else
                pcall(self.SetPropagateKeyboardInput, self, true)
            end
        end)
    end

    CreateQuestFrameSpeakerButton()

    -- If QuestFrame is already visible at hook time (addon loaded late), read it now.
    if qf.IsShown and qf:IsShown() then
        ReadQuestFrame("already visible", false)
    end

    DebugLog("QuestFrame: hook setup complete")
    return true
end

local function StartQuestFrameDiscover()
    if qfHookDone then return end
    if HookQuestFrame() then return end
    if NS and NS.IsAddonAvailable and not NS.IsAddonAvailable("Blizzard_UIPanels_Game",
        "Blizzard_QuestUI") then return end
    if qfDiscTicker then return end
    if not (C_Timer and C_Timer.NewTicker) then return end
    qfDiscTicker = C_Timer.NewTicker(1.5, function()
        if HookQuestFrame() then
            pcall(function() qfDiscTicker:Cancel() end)
            qfDiscTicker = nil
            DebugLog("QuestFrame: discover ticker stopped (hooked)")
        end
    end)
    DebugLog("QuestFrame: discover ticker started (polling every 1.5 s)")
end

-- ========= GossipFrame reader =========
--
-- Reads the NPC greeting text and gossip option names when GossipFrame opens.
-- Uses C_GossipInfo API (GetText, GetOptions, GetAvailableQuests, GetActiveQuests)
-- for reliable text extraction, with a CollectFrameText fallback.
-- Gated by UiTTSDB.readGossipFrame.

local GF_READ_DELAY   = 0.1
-- The gossip window is populated over the frames that follow GOSSIP_SHOW (the
-- ScrollBox acquires its option rows from a pool), so a single read attempt can
-- legitimately find nothing. Retry a few times before giving up.
local GF_RETRY_DELAY  = 0.15
local GF_MAX_TRIES    = 6

local gfLastSpeakTxt = nil
local gfLastSpeakAt  = 0
local gfHookDone     = false
local gfReadSerial   = 0     -- invalidates retry chains of superseded reads
local gfSpeakerBtn   = nil
local gfDiscTicker   = nil

local function SpeakGossipFrame(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end
    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    -- Both GOSSIP_SHOW and GossipFrame:OnShow trigger a read for the same
    -- window, so the identical-text guard is unconditional here (a short 1 s
    -- window) and only the longer 2 s window honours skipSameText.
    if text == gfLastSpeakTxt and (now - gfLastSpeakAt) < 1.0 then
        DebugLog("GossipFrame: duplicate read — skipped identical text")
        return
    end
    if UiTTSDB.skipSameText and text == gfLastSpeakTxt
        and (now - gfLastSpeakAt) < 2.0 then
        DebugLog("GossipFrame: isolated dedup — skipped identical text")
        return
    end
    if (now - gfLastSpeakAt) < minInterval then
        DebugLog("GossipFrame: minInterval — skipped")
        return
    end
    gfLastSpeakTxt = text
    gfLastSpeakAt  = now
    DebugLog("[GossipFrame]", text:sub(1, 120))
    Speak(text)
end

-- pcall wrapper: C_GossipInfo getters can be absent on some clients, and a
-- restricted (secret) return would otherwise abort the whole build.
local function GossipCall(fnName)
    if not C_GossipInfo or type(C_GossipInfo[fnName]) ~= "function" then return nil end
    local ok, res = pcall(C_GossipInfo[fnName])
    if not ok then return nil end
    if NS and NS.IsSecretValue and NS.IsSecretValue(res) then return nil end
    if type(res) == "table" and NS and NS.CanAccessTable and not NS.CanAccessTable(res) then return nil end
    return res
end

-- True while a gossip conversation is open, even before the frame exists.
local function GossipIsOpen()
    local gf = _G.GossipFrame
    if gf and gf.IsShown then
        local ok, shown = pcall(gf.IsShown, gf)
        if ok and shown then return true end
        -- A replacement dialog addon (e.g. DialogueUI) hides Blizzard's frame
        -- and reads its own buttons on hover; don't double-speak for it.
        if ok then return false end
    end
    -- No usable frame (not loaded yet, or replaced): trust the API, which only
    -- returns data while a gossip is actually open.
    local opts = GossipCall("GetOptions")
    if type(opts) == "table" and #opts > 0 then return true end
    local txt = GossipCall("GetText")
    return type(txt) == "string" and txt ~= ""
end

local function BuildGossipFrameText()
    local parts, seen = {}, {}
    local gotEntries = false   -- any quest or option came back from the API

    local function add(text)
        if not text or seen[text] then return end
        seen[text] = true
        parts[#parts + 1] = text
    end

    local greet = CleanText(GossipCall("GetText"))
    if greet then add(greet) end

    for _, fnName in ipairs({ "GetAvailableQuests", "GetActiveQuests" }) do
        local quests = GossipCall(fnName)
        if type(quests) == "table" then
            for _, q in ipairs(quests) do
                if type(q) == "table" and (not NS or not NS.CanAccessTable or NS.CanAccessTable(q)) then
                    local name = CleanText(q.title or q.name)
                    if name then add(name); gotEntries = true end
                end
            end
        end
    end

    local opts = GossipCall("GetOptions")
    if type(opts) == "table" then
        for _, opt in ipairs(opts) do
            if type(opt) == "table" and (not NS or not NS.CanAccessTable or NS.CanAccessTable(opt)) then
                local name = CleanText(opt.name)
                if name then add(name); gotEntries = true end
            end
        end
    end

    -- Scrape the frame tree whenever the API gave us no selectable entries —
    -- either it returned nothing at all, or the option rows live only in the
    -- ScrollBox (custom skins, secret values). Exact duplicates are dropped by
    -- `add`, so merging is safe when the greeting already came from the API.
    if not gotEntries and CollectFrameText and _G.GossipFrame then
        local ok, lines = pcall(CollectFrameText, _G.GossipFrame, {}, 0, {})
        if ok and lines and #lines > 0 then
            yutil.sort(lines)
            local maxLines = (UiTTSDB and UiTTSDB.maxLines) or 12
            for _, l in ipairs(lines) do
                if #parts >= maxLines then break end
                add(l.text)
            end
        end
    end

    if #parts == 0 then return nil end
    return table.concat(parts, ". ")
end

-- force=true bypasses dedup and restarts the read (speaker button / R key).
local function ReadGossipFrame(source, force)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readGossipFrame then return end

    gfReadSerial = gfReadSerial + 1
    local serial = gfReadSerial

    local function attempt(tries)
        -- A newer read (new NPC, next gossip page) supersedes this retry chain.
        if serial ~= gfReadSerial then return end

        -- "Not open yet" is retried like "no text yet": on GOSSIP_SHOW our
        -- handler can run before Blizzard's, i.e. before the frame is shown.
        local text = GossipIsOpen() and BuildGossipFrameText() or nil
        if not text then
            if tries < GF_MAX_TRIES and C_Timer and C_Timer.After then
                C_Timer.After(GF_RETRY_DELAY, function() attempt(tries + 1) end)
            else
                DebugLog("GossipFrame: no text extracted (source:", source or "?", ")")
            end
            return
        end

        if force then
            gfLastSpeakTxt = nil
            StopSpeaking()
        end
        DebugLog("GossipFrame read [" .. (source or "?") .. "] try " .. tries .. ":",
            text:sub(1, 120))
        SpeakGossipFrame(text)
    end

    local delay = force and 0 or GF_READ_DELAY
    if C_Timer and C_Timer.After and delay > 0 then
        C_Timer.After(delay, function() attempt(1) end)
    else
        attempt(1)
    end
end

-- ---- Gossip option hover reading ----
--
-- The option rows are not standard named buttons: Blizzard builds them inside
-- GossipFrame.GreetingPanel's ScrollBox, and skins such as DMHC create their own
-- rows (Interface/AddOns/DMHC/Gossip.lua). What they have in common is being
-- mouse-enabled frames somewhere under GossipFrame, so OnEnter is hooked on
-- every mouse-enabled descendant instead of matching names or templates.
--
-- Everything lives in one table on purpose: this file is close to Lua's 200
-- locals-per-chunk limit, and a module table costs a single local.
local gossipOpt = {
    DEPTH     = 8,      -- how deep to walk below GossipFrame
    MAX_LINES = 6,      -- one option row; keeps an accidental container read short
    INTERVAL  = 0.5,    -- rescan period while the window is open
    lastText  = nil,    -- isolated dedup state (never touches other readers)
    lastAt    = 0,
    ticker    = nil,
}

function gossipOpt.OnEnter(self)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readGossipOptionsHover then return end

    local gf = _G.GossipFrame
    if not gf or (gf.IsShown and not gf:IsShown()) then return end

    -- Containers (the greeting panel, the ScrollBox) are mouse-enabled too;
    -- hovering the gaps between rows would otherwise read the whole list.
    -- An option row is a small fraction of the window's height.
    local okG, gh = pcall(gf.GetHeight, gf)
    local function TooBig(frame)
        if not (okG and gh and gh > 0) then return false end
        local okH, h = pcall(frame.GetHeight, frame)
        return okH and h and h > gh * 0.5
    end
    if TooBig(self) then return end

    local text = BuildSortedText(self, gossipOpt.MAX_LINES)
    if not text then
        -- Some skins put the mouse-enabled hit area on a bare child frame with
        -- no FontStrings of its own; the label then lives on the parent row.
        local parent = self.GetParent and self:GetParent()
        if parent and parent ~= gf and not TooBig(parent) then
            text = BuildSortedText(parent, gossipOpt.MAX_LINES)
        end
    end
    if not text then return end

    local now = GetTime()
    if text == gossipOpt.lastText and (now - gossipOpt.lastAt) < 1.0 then return end
    if (now - gossipOpt.lastAt) < (tonumber(UiTTSDB.minInterval) or 0) then return end
    gossipOpt.lastText = text
    gossipOpt.lastAt   = now
    DebugLog("Gossip option hover:", text:sub(1, 80))
    Speak(text)
end

-- Hooks OnEnter on every mouse-enabled descendant not hooked yet.
-- Returns how many were newly hooked.
function gossipOpt.HookTree(frame, depth)
    if not frame or depth > gossipOpt.DEPTH then return 0 end
    if frame.IsForbidden and frame:IsForbidden() then return 0 end

    local ok, kids = pcall(function() return { frame:GetChildren() } end)
    if not ok or not kids then return 0 end

    local count = 0
    for _, child in ipairs(kids) do
        if child and not (child.IsForbidden and child:IsForbidden()) then
            -- IsPCFrameMouseEnabled is generic despite the name: Button /
            -- CheckButton by type, or any frame with EnableMouse(true).
            if not child.__UiTTSGossipOptHooked and IsPCFrameMouseEnabled(child) then
                child.__UiTTSGossipOptHooked = true
                TryHookScript(child, "OnEnter", gossipOpt.OnEnter)
                count = count + 1
            end
            count = count + gossipOpt.HookTree(child, depth + 1)
        end
    end
    return count
end

-- Rescans while the window is open: rows are pooled and rebuilt per NPC, so
-- new frames appear after the window is already visible.
function gossipOpt.Scan()
    if not (UiTTSDB and UiTTSDB.readGossipOptionsHover) then return end
    local gf = _G.GossipFrame
    if not gf or (gf.IsShown and not gf:IsShown()) then return end
    local n = gossipOpt.HookTree(gf, 1)
    if n > 0 then
        DebugLog("Gossip: hooked", n, "option frame(s) for hover reading")
    end
end

local function CreateGossipFrameSpeakerButton()
    if gfSpeakerBtn then return end
    local gf = _G.GossipFrame
    if not gf or not gf.GetFrameLevel then return end

    local ok, btn = pcall(CreateFrame, "Button", "UiTTSGossipFrameSpeakerButton", gf)
    if not ok or not btn then return end
    btn:SetSize(22, 22)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel((gf:GetFrameLevel() or 0) + 10)

    local close = gf.CloseButton or _G.GossipFrameCloseButton
    if close then
        btn:SetPoint("RIGHT", close, "LEFT", -2, 0)
    else
        btn:SetPoint("TOPRIGHT", gf, "TOPRIGHT", -38, -14)
    end

    -- Same icon fallback chain as the QuestFrame button: atlas, then texture,
    -- then a plain "TTS" label so the control is always discoverable.
    local iconApplied = false
    if btn.SetNormalAtlas then
        local okAtlas = pcall(btn.SetNormalAtlas, btn, "voicechat-speaker-on")
        if okAtlas then
            pcall(btn.SetHighlightAtlas, btn, "voicechat-speaker-on")
            iconApplied = true
        end
    end
    if not iconApplied then
        local okTex = pcall(function()
            btn:SetNormalTexture("Interface\\Common\\VoiceChat-Speaker")
            btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        end)
        if not okTex then
            local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            fs:SetAllPoints(btn)
            fs:SetText("TTS")
        end
    end

    btn:SetScript("OnClick", function()
        ReadGossipFrame("speaker button", true)
    end)
    btn:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("UiTTS")
            GameTooltip:AddLine((L and L["Read dialog again (R)"]) or "Read dialog again (R)",
                1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    gfSpeakerBtn = btn
    DebugLog("GossipFrame: speaker button created")
end

local function HookGossipFrame()
    if gfHookDone then return true end
    local gf = _G.GossipFrame
    if not gf then return false end
    gfHookDone = true

    DebugLog("GossipFrame: hooking")

    TryHookScript(gf, "OnShow", function()
        ReadGossipFrame("OnShow", false)
        -- Rows are built as the window shows; catch them right away instead of
        -- waiting for the next scanner tick.
        if C_Timer and C_Timer.After then
            C_Timer.After(0.05, gossipOpt.Scan)
            C_Timer.After(0.30, gossipOpt.Scan)
        else
            gossipOpt.Scan()
        end
    end)

    TryHookScript(gf, "OnHide", function()
        gfLastSpeakTxt = nil
        gossipOpt.lastText = nil
    end)

    -- Cheap scanner: walks only GossipFrame's subtree, and only while it is
    -- shown, so newly pooled / recreated option rows get hooked.
    if not gossipOpt.ticker and C_Timer and C_Timer.NewTicker then
        gossipOpt.ticker = C_Timer.NewTicker(gossipOpt.INTERVAL, gossipOpt.Scan)
    end
    gossipOpt.Scan()

    -- "R" restarts the read while the window is open, matching QuestFrame.
    -- Keyboard input keeps propagating unless we actually act on the key.
    local okKb = pcall(function() gf:EnableKeyboard(true) end)
    if okKb then
        pcall(function() gf:SetPropagateKeyboardInput(true) end)
        TryHookScript(gf, "OnKeyDown", function(self, key)
            if IsChatInputActive() then
                pcall(self.SetPropagateKeyboardInput, self, true)
                return
            end
            if key == "R"
                and UiTTSDB and UiTTSDB.enabled and UiTTSDB.readGossipFrame
                and self:IsShown() then
                pcall(self.SetPropagateKeyboardInput, self, false)
                ReadGossipFrame("R key", true)
            else
                pcall(self.SetPropagateKeyboardInput, self, true)
            end
        end)
    end

    CreateGossipFrameSpeakerButton()

    if gf.IsShown and gf:IsShown() then
        ReadGossipFrame("already visible", false)
    end

    DebugLog("GossipFrame: hook setup complete")
    return true
end

-- Forever's GossipFrame lives in Blizzard_UIPanels_Game; other clients can use
-- Blizzard_GossipFrame. Either module can become available after
-- PLAYER_LOGIN. Without this ticker the two login hook passes were the only
-- attempts, so a late frame was never hooked and no gossip was ever read.
local function StartGossipFrameDiscover()
    if gfHookDone then return end
    if HookGossipFrame() then return end
    if NS and NS.IsAddonAvailable and not NS.IsAddonAvailable("Blizzard_UIPanels_Game",
        "Blizzard_GossipFrame", "Blizzard_GossipFrameShared") then return end
    if gfDiscTicker then return end
    if not (C_Timer and C_Timer.NewTicker) then return end
    gfDiscTicker = C_Timer.NewTicker(1.5, function()
        if HookGossipFrame() then
            pcall(function() gfDiscTicker:Cancel() end)
            gfDiscTicker = nil
            DebugLog("GossipFrame: discover ticker stopped (hooked)")
        end
    end)
    DebugLog("GossipFrame: discover ticker started (polling every 1.5 s)")
end

-- ========= GuildRegistrarFrame reader =========
--
-- Reads the greeting text and service-list options of GuildRegistrarFrame
-- (the dialog that opens when speaking with a Guild Master / Petitioner NPC).
-- Gated by UiTTSDB.readGuildRegistrar.

local GR_READ_DELAY = 0.1

local grLastSpeakTxt = nil
local grLastSpeakAt  = 0
local grHookDone     = false

local function SpeakGuildRegistrar(text)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not text then return end
    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if UiTTSDB.skipSameText and text == grLastSpeakTxt
        and (now - grLastSpeakAt) < 2.0 then
        DebugLog("GuildRegistrar: isolated dedup — skipped identical text")
        return
    end
    if (now - grLastSpeakAt) < minInterval then
        DebugLog("GuildRegistrar: minInterval — skipped")
        return
    end
    grLastSpeakTxt = text
    grLastSpeakAt  = now
    DebugLog("[GuildRegistrar]", text:sub(1, 120))
    Speak(text)
end

local function BuildGuildRegistrarText()
    local f = _G.GuildRegistrarFrame
    if not f then return nil end

    local parts = {}

    -- Greeting text is the primary string on the dialog.
    local greet = _G.GuildRegistrarGreetingText
    if greet and greet.GetText then
        local t = CleanText(greet:GetText())
        if t then parts[#parts + 1] = t end
    end

    -- Purchase button label (when shown). Other service entries are dynamic and
    -- caught by the CollectFrameText fallback below.
    local purchase = _G.GuildRegistrarPurchaseText
    if purchase and purchase.GetText and (not purchase.IsShown or purchase:IsShown()) then
        local t = CleanText(purchase:GetText())
        if t then parts[#parts + 1] = t end
    end

    -- Walk the frame tree for any other visible labels (service list rows, etc).
    if CollectFrameText then
        local lines = CollectFrameText(f, {}, 0, {})
        if lines and #lines > 0 then
            yutil.sort(lines)
            local seen = {}
            for _, p in ipairs(parts) do seen[p] = true end
            local maxLines = (UiTTSDB and UiTTSDB.maxLines) or 12
            for _, l in ipairs(lines) do
                if #parts >= maxLines then break end
                if not seen[l.text] then
                    seen[l.text] = true
                    parts[#parts + 1] = l.text
                end
            end
        end
    end

    if #parts == 0 then return nil end
    return table.concat(parts, ". ")
end

local function ReadGuildRegistrar(source, force)
    if not UiTTSDB or not UiTTSDB.enabled then return end
    if not UiTTSDB.readGuildRegistrar then return end

    local f = _G.GuildRegistrarFrame
    if not f or (f.IsShown and not f:IsShown()) then return end

    local function doRead()
        if f.IsShown and not f:IsShown() then return end
        local text = BuildGuildRegistrarText()
        if not text then
            DebugLog("GuildRegistrar: no text extracted (source:", source or "?", ")")
            return
        end
        if force then
            grLastSpeakTxt = nil
            StopSpeaking()
        end
        DebugLog("GuildRegistrar read [" .. (source or "?") .. "]:", text:sub(1, 120))
        SpeakGuildRegistrar(text)
    end

    if C_Timer and C_Timer.After and GR_READ_DELAY > 0 then
        C_Timer.After(GR_READ_DELAY, doRead)
    else
        doRead()
    end
end

local function HookGuildRegistrarFrame()
    if grHookDone then return true end
    local f = _G.GuildRegistrarFrame
    if not f then return false end
    grHookDone = true

    DebugLog("GuildRegistrar: hooking")

    TryHookScript(f, "OnShow", function()
        ReadGuildRegistrar("OnShow", false)
    end)

    TryHookScript(f, "OnHide", function()
        grLastSpeakTxt = nil
    end)

    if f.IsShown and f:IsShown() then
        ReadGuildRegistrar("already visible", false)
    end

    DebugLog("GuildRegistrar: hook setup complete")
    return true
end

-- ========= Init =========

local uiReaderFrame = CreateFrame("Frame")
uiReaderFrame:RegisterEvent("PLAYER_LOGIN")
uiReaderFrame:RegisterEvent("ADDON_LOADED")
-- UI_ERROR_MESSAGE / UI_INFO_MESSAGE are available from the first frame;
-- register upfront so no messages are missed between load and PLAYER_LOGIN.
uiReaderFrame:RegisterEvent("UI_ERROR_MESSAGE")
uiReaderFrame:RegisterEvent("UI_INFO_MESSAGE")
-- Raid warnings / boss emotes: event fallback for the RaidNotice_AddMessage
-- hook. Both paths carry the same text, and SpeakRaidWarning's duplicate guard
-- drops whichever arrives second.
uiReaderFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
uiReaderFrame:RegisterEvent("RAID_BOSS_EMOTE")
uiReaderFrame:RegisterEvent("RAID_BOSS_WHISPER")
-- DialogueUI acquires its option buttons from a pool the moment one of these
-- fires, so they are the exact points at which a rescan can find something
-- new.  Reacting to them keeps hooking instant without making the fallback
-- ticker scan more often (see ScanDUIDialogOptionButtons' backoff).
-- GOSSIP_SHOW additionally drives the GossipFrame reader itself: it is the only
-- reliable signal when the window is reused (picking an option swaps the page
-- without a new OnShow) or when Blizzard_GossipFrame is created late.
uiReaderFrame:RegisterEvent("GOSSIP_SHOW")
uiReaderFrame:RegisterEvent("GOSSIP_CLOSED")
uiReaderFrame:RegisterEvent("QUEST_GREETING")
uiReaderFrame:RegisterEvent("QUEST_DETAIL")
uiReaderFrame:RegisterEvent("QUEST_PROGRESS")
uiReaderFrame:RegisterEvent("QUEST_COMPLETE")

-- arg1 / arg2 cover all event signatures used below:
--   ADDON_LOADED     : arg1 = addonName
--   UI_ERROR_MESSAGE : arg1 = messageType (Enum.UiErrorMessage), arg2 = message text
--   UI_INFO_MESSAGE  : arg1 = messageType,                        arg2 = message text
uiReaderFrame:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "UI_ERROR_MESSAGE" or event == "UI_INFO_MESSAGE" then
        -- arg1 = messageType (number), arg2 = message text (string) in WoW Retail 10.x+.
        -- Fall back to arg1 as the text for older API layouts where arg1 was the string.
        local text = CleanText(arg2) or CleanText(arg1)
        if text then
            DebugLog("UIErrors event [" .. event .. "]:", text:sub(1, 80))
            SpeakUIError(text)
        end
        return
    end

    if event == "CHAT_MSG_RAID_WARNING"
        or event == "RAID_BOSS_EMOTE"
        or event == "RAID_BOSS_WHISPER"
    then
        -- arg1 = message text for all three events.
        local text = CleanText(arg1)
        if text then
            DebugLog("RaidWarning event [" .. event .. "]:", text:sub(1, 80))
            SpeakRaidWarning(text)
        end
        return
    end

    if event == "GOSSIP_CLOSED" then
        gfLastSpeakTxt = nil
        gfReadSerial   = gfReadSerial + 1   -- drop any pending retry chain
        return
    end

    if event == "GOSSIP_SHOW" then
        -- Hook now if the frame only just appeared, then read the conversation.
        StartGossipFrameDiscover()
        ReadGossipFrame("GOSSIP_SHOW", false)
        -- Option rows are (re)built for this NPC; hook them for hover reading.
        if C_Timer and C_Timer.After then
            C_Timer.After(0.05, gossipOpt.Scan)
            C_Timer.After(0.30, gossipOpt.Scan)
        else
            gossipOpt.Scan()
        end
    end

    if event == "GOSSIP_SHOW"
        or event == "QUEST_GREETING"
        or event == "QUEST_DETAIL"
        or event == "QUEST_PROGRESS"
        or event == "QUEST_COMPLETE"
    then
        -- Forever can reuse an already-visible quest panel for a new page.
        -- The event still fires even when the panel's OnShow does not.
        if event ~= "GOSSIP_SHOW" then
            StartQuestFrameDiscover()
            ReadQuestFrame(event, false)
        end
        -- Defer a tick: the pool is filled by DialogueUI's own handler for the
        -- same event, which may run after ours.
        if C_Timer and C_Timer.After then
            C_Timer.After(0.05, function() ScanDUIDialogOptionButtons(true) end)
        else
            ScanDUIDialogOptionButtons(true)
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        -- Defer by one frame so all global frames are fully initialised
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                HookGameMenuButtons()
                HookSettingsPanel()
                HookSettingsTooltip()
                HookEventToastManager()
                HookPlayerChoiceFrame()
                HookScenarioTracker()
                HookUIErrorsFrame()
                HookRaidWarningFrames()
                StartAlliedRacesDiscover()
                StartShopDiscover()
                catShop.Start()
                StartDUIDialogOptionDiscover()
                StartQuestFrameDiscover()
                StartGossipFrameDiscover()
                HookGuildRegistrarFrame()
                HookPVEFrame()
            end)
            -- Second pass to catch anything that resolves a tick later
            C_Timer.After(1.0, function()
                HookGameMenuButtons()
                HookSettingsPanel()
                HookSettingsTooltip()
                HookEventToastManager()
                HookPlayerChoiceFrame()
                HookScenarioTracker()
                HookUIErrorsFrame()
                HookRaidWarningFrames()
                StartAlliedRacesDiscover()
                StartShopDiscover()
                catShop.Start()
                StartDUIDialogOptionDiscover()
                StartQuestFrameDiscover()
                StartGossipFrameDiscover()
                HookGuildRegistrarFrame()
                HookPVEFrame()
            end)
        else
            HookGameMenuButtons()
            HookSettingsPanel()
            HookSettingsTooltip()
            HookEventToastManager()
            HookPlayerChoiceFrame()
            HookScenarioTracker()
            HookUIErrorsFrame()
            HookRaidWarningFrames()
            HookAlliedRacesFrame()
            HookStoreFrame()
            catShop.Start()
            StartDUIDialogOptionDiscover()
            HookQuestFrame()
            StartGossipFrameDiscover()
            HookGuildRegistrarFrame()
            HookPVEFrame()
        end

        return
    end

    if event == "ADDON_LOADED" then
        local addonName = arg1   -- rename for clarity within this block

        if addonName == "Blizzard_GameMenu" then
            HookGameMenuButtons()
        end

        -- Settings-related modules load lazily; re-run hooks when they arrive
        if addonName == "Blizzard_Settings"
            or addonName == "Blizzard_SettingsDefinitions"
            or addonName == "Blizzard_Settings_Shared"
            or addonName == "Blizzard_SettingsDefinitions_Shared"
            or addonName == "Blizzard_SettingsDefinitions_Frame"
            or addonName == "Blizzard_UIParent"
        then
            HookSettingsPanel()
            HookSettingsTooltip()
        end

        -- EventToastManagerFrame lives in the base UI but may be registered as
        -- part of Blizzard_UIParent or similar; re-run the hook on any candidate.
        if addonName == "Blizzard_UIParent"
            or addonName == "Blizzard_EventToast"
            or addonName == "Blizzard_ObjectiveTracker"
        then
            HookEventToastManager()
        end

        -- PlayerChoiceFrame is created by Blizzard_PlayerChoice; hook it as soon
        -- as that module finishes loading.
        if addonName == "Blizzard_PlayerChoice" then
            HookPlayerChoiceFrame()
        end

        -- AlliedRacesFrame is lazy-created; retry on any addon load in case
        -- the frame just became available (no single known addon triggers it).
        StartAlliedRacesDiscover()

        -- Store frame: watch for known Blizzard shop addon names.
        if addonName == "Blizzard_Store"
            or addonName == "Blizzard_StoreUI"
            or addonName == "Blizzard_CatalogShop"
            or addonName == "Blizzard_PremiumStore"
        then
            StartShopDiscover()
        end

        -- Retail 12.x shop: Blizzard_CatalogShop is load-on-demand, so
        -- CatalogShopFrame only exists once the player opens the shop.
        if addonName == "Blizzard_CatalogShop" then
            catShop.Start()
        end

        -- ScenarioObjectiveTracker lives in Blizzard_ObjectiveTracker; also
        -- retry on UIParent in case the frame is part of the base UI bundle.
        if addonName == "Blizzard_ObjectiveTracker"
            or addonName == "Blizzard_UIParent"
        then
            HookScenarioTracker()
        end

        -- UIErrorsFrame is part of the base UI; retry AddMessage hook on UIParent load.
        if addonName == "Blizzard_UIParent" then
            HookUIErrorsFrame()
            HookRaidWarningFrames()
            HookGuildRegistrarFrame()
        end

        if addonName == "Blizzard_UIPanels_Game" then
            StartQuestFrameDiscover()
            StartGossipFrameDiscover()
            HookGuildRegistrarFrame()
        end

        -- DialogueUI loads its option-button template lazily; force a rescan
        -- as soon as the addon finishes loading so first-time gossip menus
        -- speak buttons immediately instead of waiting for the next 2 s tick.
        if addonName == "DialogueUI" then
            StartDUIDialogOptionDiscover()
        end

        -- Blizzard_QuestUI creates QuestFrame lazily on some clients; try to
        -- hook as soon as the addon finishes loading.
        if addonName == "Blizzard_QuestUI"
            or addonName == "Blizzard_UIParent"
        then
            StartQuestFrameDiscover()
        end

        -- Same for GossipFrame, which lives in its own Blizzard module.
        if addonName == "Blizzard_GossipFrame"
            or addonName == "Blizzard_GossipFrameShared"
            or addonName == "Blizzard_UIParent"
        then
            StartGossipFrameDiscover()
        end

        -- PVEFrame (Group Finder) is created by the LFG / PVE module; hook it
        -- as soon as any plausible addon for it finishes loading.
        if addonName == "Blizzard_LFGList"
            or addonName == "Blizzard_LookingForGroup"
            or addonName == "Blizzard_PVEFrame"
            or addonName == "Blizzard_UIParent"
        then
            HookPVEFrame()
        end
    end
end)
