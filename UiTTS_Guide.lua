-- UiTTS_Guide.lua (WoW Forever Beta 1.60.x / modern Settings API)
--
-- Adds a "Guide" tab (subcategory) under the UiTTS options that explains what
-- the addon does and what every option does. Each guide entry has a speaker
-- button that reads that entry aloud through the addon's own TTS, so the guide
-- itself is accessible to a user who relies on speech. A button at the top
-- reads the whole guide in order.
--
-- Explanations reuse the exact same L[...] keys as the options panel, so they
-- are already translated in every locale that ships translations.

local L  = UiTTS_L
local NS = UiTTS_NS

-- Explicit user action: read even if automatic reading is toggled off.
local SpeakForced = (NS and NS.SpeakForced) or (NS and NS.Speak) or function() end
local StopSpeaking = (NS and NS.StopSpeaking) or function()
    if C_VoiceChat and C_VoiceChat.StopSpeakingText then C_VoiceChat.StopSpeakingText() end
end

-- Guide structure: a list of sections, each with a header and entries. Every
-- entry is { titleKey, bodyKey }. Keys marked "guide-only" are defined below in
-- enUS/ptBR; option keys reuse the already-translated options strings.
local SECTIONS = {
    {
        header = "How to use UiTTS",
        entries = {
            { "What is UiTTS?",
              "UiTTS reads tooltips and interface text aloud using World of Warcraft's built-in Text-to-Speech engine. It is meant to make the game more accessible: hover something, or open a window, and UiTTS speaks what is there. Use the checkboxes on the Options tab to choose exactly what is read." },
            { "Getting started",
              "Everything is on by default except the noisier chat channels. Turn the master switch on or off with the 'Enable UiTTS' option or the slash command /uitts toggle. If speech ever gets stuck, press your Stop keybinding or type /uitts stop." },
        },
    },
    {
        header = "Commands and keybindings",
        entries = {
            { "Slash commands",
              "Type /uitts on to enable, /uitts off to disable, /uitts toggle to switch, /uitts stop to stop speaking, /uitts repeat to hear the last thing spoken again, /uitts config to open the options, and /uitts guide to open this guide." },
            { "Keybindings",
              "In the game's Key Bindings window, under the UiTTS category, you can bind four actions: toggle UiTTS on or off, stop speaking, repeat the last spoken text, and read the tooltip currently under the mouse on demand." },
        },
    },
    {
        header = "Voice output",
        entries = {
            { "Use Alternate voice", "Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)." },
            { "Use custom speech rate/volume", "Overrides WoW's chat TTS rate and volume with the values below. When off, UiTTS follows WoW's Text-to-Speech settings." },
            { "Speech rate (-10 to 10)", "Speech speed used when 'Use custom speech rate/volume' is enabled. Negative is slower, positive is faster." },
            { "Speech volume (0 to 100)", "Speech volume used when 'Use custom speech rate/volume' is enabled." },
        },
    },
    {
        header = "General",
        entries = {
            { "Enable UiTTS", "Turns the addon on/off entirely. When disabled, no text is read." },
            { "Interrupt speech when tooltip changes", "Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish." },
            { "Do not repeat identical text", "If the final text matches the last spoken text for the same tooltip, suppress the repeat." },
        },
    },
    {
        header = "Reading categories",
        entries = {
            { "Read tooltips (master)", "Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below." },
            { "GameTooltip (items / general UI)", "Reads standard game tooltips when hovering items, abilities, and general UI elements." },
            { "Minimap objects (icons/buttons)", "Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons." },
            { "Spellbook", "Reads tooltips when hovering abilities in the spellbook." },
            { "Talent tree", "Reads tooltips when hovering talents in the character talent tree." },
            { "Profession specializations", "Reads specialization tooltips on the Professions screen, including specialization and unlock nodes." },
            { "Trading Post / Perks", "Reads Trading Post and Perks Program tooltips when hovering rewards and items.",
              available = not NS or NS.HasTradingPost ~= false },
            { "Quest rewards (incl. DialogueUI)", "Reads quest reward tooltips in native game UIs and addons such as DialogueUI." },
            { "Quest window (QuestFrame)", "Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read." },
            { "NPC dialog window (GossipFrame)", "Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read." },
            { "NPC dialog options on hover", "Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC." },
            { "Guild Registrar window", "Reads the greeting and service list of the Guild Master / Petitioner dialog." },
            { "DialogueUI option buttons", "Reads the label of DialogueUI gossip / accept / exit buttons when hovered." },
            { "Item links in chat", "Reads tooltips when clicking item links in chat." },
            { "Shopping comparison (ShoppingTooltip)", "Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard." },
            { "Capture dynamic tooltips (scan)", "Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI." },
        },
    },
    {
        header = "Interface / UI buttons",
        entries = {
            { "Game menu (ESC)", "Reads the button label when hovering items in the menu opened by pressing ESC." },
            { "Settings buttons and controls", "Reads the visible label of controls in the Settings panel when hovered." },
            { "Settings option tooltips", "Reads the title and description of the tooltip shown when hovering a Settings option." },
            { "Read center notifications / Event Toasts", "Reads center-screen notifications such as completed objectives and event starts." },
            { "Read Group Finder banners", "Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears." },
            { "Read center screen messages (UIErrors)", "Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions." },
            { "Read raid warnings and boss emotes", "Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements." },
            { "Read choice options (PlayerChoice)", "Reads the title and description of an option/card when hovered in the player choice window." },
            { "Read objective tracker events", "Reads timed events from the objective tracker, including time remaining and progress collected." },
            { "Read information panels", "Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area." },
            { "Read shop UI", "Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'." },
        },
    },
    {
        header = "Chat and events",
        entries = {
            { "Read whispers", "Reads incoming whispers (player and Battle.net), including the sender's name." },
            { "Read party chat", "Reads messages in party chat, including the sender's name." },
            { "Read say", "Reads nearby 'say' messages, including the speaker's name." },
            { "Read guild chat", "Reads guild chat messages, including the sender's name." },
            { "Read yell", "Reads nearby 'yell' messages, including the speaker's name." },
            { "Read loot messages", "Reads loot messages such as items and money you receive." },
            { "Read target changes", "Announces the name and level of your target whenever it changes." },
        },
    },
    {
        header = "Experience / leveling",
        entries = {
            { "Read XP gains", "Reads how much experience the player gains, summarised in short batches." },
            { "Read level-ups", "Announces the new level when the player levels up." },
        },
    },
    {
        header = "Stability / performance",
        entries = {
            { "Debounce (sec)", "Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly." },
            { "Minimum global interval (sec)", "Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly." },
            { "Scan interval (sec)", "How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU." },
            { "Per-owner time lock (sec) (optional)", "After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events." },
            { "Max lines read per tooltip", "Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads." },
        },
    },
}

-- Small speaker button that reads `getText()` when clicked.
local function CreateSpeakerButton(parent, getText)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(20, 20)

    local applied = false
    if btn.SetNormalAtlas then
        local ok = pcall(btn.SetNormalAtlas, btn, "voicechat-speaker-on")
        if ok then
            pcall(btn.SetHighlightAtlas, btn, "voicechat-speaker-on")
            applied = true
        end
    end
    if not applied then
        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetAllPoints(btn)
        fs:SetText("TTS")
    end

    btn:SetScript("OnClick", function()
        StopSpeaking()
        local t = getText()
        if t and t ~= "" then SpeakForced(t) end
    end)
    btn:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(L["Read this section"])
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    return btn
end

-- Match the options panel when a UI feature is excluded from this client.
for _, section in ipairs(SECTIONS) do
    for i = #section.entries, 1, -1 do
        if section.entries[i].available == false then table.remove(section.entries, i) end
    end
end

local function BuildGuidePanel()
    local panel = CreateFrame("Frame")
    panel.name = L["Guide"]

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(L["How to use UiTTS"])

    -- "Read entire guide" button next to the title.
    local fullText   -- filled in after all entries are collected
    local readAll = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    readAll:SetSize(160, 22)
    readAll:SetPoint("TOPRIGHT", -28, -14)
    readAll:SetText(L["Read entire guide"])
    readAll:SetScript("OnClick", function()
        StopSpeaking()
        if fullText and fullText ~= "" then SpeakForced(fullText) end
    end)

    local scrollFrame = CreateFrame("ScrollFrame", "UiTTSGuideScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -48)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 4)

    local scrollChild = CreateFrame("Frame", "UiTTSGuideScrollChild", scrollFrame)
    scrollChild:SetWidth(560)
    scrollFrame:SetScrollChild(scrollChild)

    local allParts = {}
    local y = -8

    for _, section in ipairs(SECTIONS) do
        local head = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        head:SetPoint("TOPLEFT", 16, y)
        head:SetText(L[section.header])
        allParts[#allParts + 1] = L[section.header]
        y = y - 24

        for _, entry in ipairs(section.entries) do
            local titleStr = L[entry[1]]
            local bodyStr  = L[entry[2]]
            local spoken   = titleStr .. ". " .. bodyStr
            allParts[#allParts + 1] = spoken

            local speaker = CreateSpeakerButton(scrollChild, function() return spoken end)
            speaker:SetPoint("TOPLEFT", 16, y)

            local titleFS = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            titleFS:SetPoint("TOPLEFT", 44, y - 2)
            titleFS:SetWidth(500)
            titleFS:SetJustifyH("LEFT")
            titleFS:SetText(titleStr)

            local titleH = titleFS:GetStringHeight() or 12
            local bodyY = y - titleH - 6

            local bodyFS = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            bodyFS:SetPoint("TOPLEFT", 44, bodyY)
            bodyFS:SetWidth(500)
            bodyFS:SetJustifyH("LEFT")
            bodyFS:SetText(bodyStr)

            local bodyH = bodyFS:GetStringHeight() or 12
            y = bodyY - bodyH - 14
        end

        y = y - 8
    end

    fullText = table.concat(allParts, ". ")
    scrollChild:SetHeight(math.abs(y) + 16)

    return panel
end

-- Register as a subcategory (tab) of the main UiTTS options category.
local function RegisterGuide()
    local parent = _G.UiTTS_OptionsCategory or _G.AbleCraft_OptionsCategory
    if not (Settings and Settings.RegisterCanvasLayoutSubcategory and parent) then return end

    -- pcall the whole build+register so a Settings API shape change can't abort
    -- addon load; the guide is a nice-to-have, the readers must still work.
    local ok, err = pcall(function()
        local panel = BuildGuidePanel()
        local okSub, sub = pcall(Settings.RegisterCanvasLayoutSubcategory, parent, panel, panel.name)
        if (not okSub or not sub) and _G.AbleCraft_OptionsCategory and parent ~= _G.AbleCraft_OptionsCategory then
            okSub, sub = pcall(Settings.RegisterCanvasLayoutSubcategory, _G.AbleCraft_OptionsCategory, panel, panel.name)
        end
        if sub then
            _G.UiTTS_GuideCategoryID = (sub.GetID and sub:GetID()) or sub.ID
        end
    end)
    if not ok and UiTTSDB and UiTTSDB.debugUIReader then
        print("|cff88aaff[UiTTS Guide]|r registration failed:", tostring(err))
    end
end

RegisterGuide()
