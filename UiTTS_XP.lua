-- UiTTS_XP.lua  (XpTTS feature)
--
-- Reads XP-related events aloud:
--   • Batched "Gained N XP." announcements when the player earns XP
--     (multiple PLAYER_XP_UPDATE events within XP_BATCH_WINDOW are summed
--     into a single read so a kill that fires several updates doesn't
--     produce a flood of speech).
--   • Level-up announcement when PLAYER_LEVEL_UP fires.
--
-- Gates: UiTTSDB.readXPGain, UiTTSDB.readLevelUp.
-- Isolated dedup state — does not suppress tooltip / UIReader speech.

local NS = UiTTS_NS
local L  = UiTTS_L

local XP_BATCH_WINDOW = 2.0   -- seconds of XP-update silence before flushing the batch

local function DebugLog(...)
    if UiTTSDB and UiTTSDB.debugUIReader then
        print("|cffffcc88[UiTTS XP]|r", ...)
    end
end

local function FallbackSpeak(text)
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

local function Speak(text)
    local s = (NS and NS.Speak) or FallbackSpeak
    s(text)
end

-- Isolated state — kept separate from UIReader / tooltip dedup tables so XP
-- announcements never silence (or get silenced by) other readers.
local xpLastKnown    = nil   -- last seen UnitXP("player"); nil before PLAYER_LOGIN
local xpAccum        = 0     -- summed delta since last spoken batch
local xpFlushPending = false -- C_Timer.After is in flight
local xpLastSpeakAt  = 0

local function FlushXPBatch()
    xpFlushPending = false
    local n = xpAccum
    xpAccum = 0
    if n <= 0 then return end
    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readXPGain) then return end

    local now = GetTime()
    local minInterval = tonumber(UiTTSDB.minInterval) or 0
    if (now - xpLastSpeakAt) < minInterval then return end
    xpLastSpeakAt = now

    local fmt  = (L and L["Gained %d XP."]) or "Gained %d XP."
    local text = string.format(fmt, n)
    DebugLog("batch ->", text)
    Speak(text)
end

local function ScheduleXPFlush()
    if xpFlushPending then return end
    xpFlushPending = true
    if C_Timer and C_Timer.After then
        C_Timer.After(XP_BATCH_WINDOW, FlushXPBatch)
    else
        FlushXPBatch()
    end
end

local function OnPlayerXPUpdate()
    local cur = UnitXP and UnitXP("player")
    if not cur then return end

    -- Always keep the baseline in sync, even when the toggle is off, so a later
    -- enable doesn't fire a single huge delta for accumulated session XP.
    if xpLastKnown == nil then
        xpLastKnown = cur
        return
    end

    local delta = cur - xpLastKnown
    xpLastKnown = cur

    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readXPGain) then return end
    -- delta < 0 happens at level-up wrap; PLAYER_LEVEL_UP handles that path.
    if delta <= 0 then return end

    xpAccum = xpAccum + delta
    ScheduleXPFlush()
end

local function OnPlayerLevelUp(newLevel)
    -- Re-baseline so the post-level XP value isn't read as a giant gain.
    xpLastKnown = (UnitXP and UnitXP("player")) or 0
    xpAccum     = 0

    if not (UiTTSDB and UiTTSDB.enabled and UiTTSDB.readLevelUp) then return end

    local lvl = tonumber(newLevel) or (UnitLevel and UnitLevel("player")) or 0
    local fmt = (L and L["Level up! Now level %d."]) or "Level up! Now level %d."
    local text = string.format(fmt, lvl)
    DebugLog("level up ->", text)
    Speak(text)
end

local xpFrame = CreateFrame("Frame")
xpFrame:RegisterEvent("PLAYER_LOGIN")
xpFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
xpFrame:RegisterEvent("PLAYER_XP_UPDATE")
xpFrame:RegisterEvent("PLAYER_LEVEL_UP")

xpFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        -- Re-sync baseline whenever the world (re)loads so XP earned during a
        -- /reload or zone transition is not mistakenly announced afterwards.
        xpLastKnown = (UnitXP and UnitXP("player")) or 0
        xpAccum     = 0
        DebugLog(event, "— baseline XP =", xpLastKnown)
        return
    end

    if event == "PLAYER_XP_UPDATE" then
        OnPlayerXPUpdate()
        return
    end

    if event == "PLAYER_LEVEL_UP" then
        OnPlayerLevelUp(arg1)
        return
    end
end)
