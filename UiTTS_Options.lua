-- UiTTS_Options.lua (WoW Forever Beta 1.60.x / modern Settings API)
--
-- Settings UI built with the WoW 12.0+ Canvas-Layout API, split into tabs:
-- a main "UiTTS" category (general + voice) plus subcategories (Tooltips,
-- Interface, Chat & events, Experience & performance). The Guide subcategory is
-- added separately by UiTTS_Guide.lua. All user-facing strings go through L.

local L  = UiTTS_L
local NS = UiTTS_NS

local function EnsureDB()
    AbleCraftDB = AbleCraftDB or UiTTSDB or {}
    UiTTSDB = AbleCraftDB
end

-- Globally-unique frame-name counters (frames on different panels must not clash).
local widgetIndex = 0
local panelIndex = 0

-- Every checkbox registers a refresher here so "Enable/Disable all" can update
-- the visible controls immediately.
local allRefreshers = {}

-- The read/scan toggles flipped by the Enable-all / Disable-all buttons.
local READ_KEYS = {
    "readTooltips", "readGameTooltip", "readMinimap", "readSpellbook", "readTalents",
    "readProfessions", "readTradingPost", "readQuestRewards", "readQuestFrame",
    "readGossipFrame", "readGossipOptionsHover", "readGuildRegistrar",
    "readDialogueUIOptions", "readItemRef",
    "readShopping", "scanDynamicTooltips", "readGameMenu", "readSettingsButtons",
    "readSettingsTooltips", "readEventToasts", "readPVENewSlice", "readUIErrors",
    "readRaidWarning",
    "readPlayerChoice", "readScenarioTrackerEvents", "readInfoPanels", "readShopUI",
    "readWhispers", "readParty", "readSay", "readGuild", "readYell", "readLoot",
    "readTargetChange", "readXPGain", "readLevelUp",
}

-- ========= Panel factory =========
-- Returns a panel plus closures that add controls, tracking the running Y offset.
local function BuildPanel(name, titleText, subText)
    local panel = CreateFrame("Frame")
    panel.name = name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(titleText or name)

    local topOffset = -40
    if subText then
        local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        sub:SetPoint("TOPLEFT", 16, -40)
        sub:SetText(subText)
        topOffset = -60
    end

    panelIndex = panelIndex + 1
    local scrollFrame = CreateFrame("ScrollFrame", "UiTTSOptScroll" .. panelIndex, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, topOffset)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 4)

    local scrollChild = CreateFrame("Frame", "UiTTSOptScrollChild" .. panelIndex, scrollFrame)
    scrollChild:SetWidth(560)
    scrollFrame:SetScrollChild(scrollChild)

    local api = { panel = panel, child = scrollChild, y = -8 }

    function api.Header(text)
        local fs = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        fs:SetPoint("TOPLEFT", 16, api.y)
        fs:SetText(text)
        api.y = api.y - 28
    end

    function api.Checkbox(label, tooltipText, key)
        widgetIndex = widgetIndex + 1
        local cb = CreateFrame("CheckButton", "UiTTSOptCB" .. widgetIndex, scrollChild, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 16, api.y)
        cb.Text:SetText(label)
        cb.tooltipText = tooltipText

        local function refresh() cb:SetChecked(UiTTSDB[key] and true or false) end
        cb:SetScript("OnShow", refresh)
        cb:SetScript("OnClick", function(self) UiTTSDB[key] = self:GetChecked() and true or false end)
        allRefreshers[#allRefreshers + 1] = refresh

        api.y = api.y - 28
        return cb
    end

    function api.Slider(label, tooltipText, minV, maxV, step, key, default)
        widgetIndex = widgetIndex + 1
        local s = CreateFrame("Slider", "UiTTSOptSlider" .. widgetIndex, scrollChild, "OptionsSliderTemplate")
        s:SetPoint("TOPLEFT", 16, api.y)
        s:SetMinMaxValues(minV, maxV)
        s:SetValueStep(step)
        s:SetObeyStepOnDrag(true)
        s:SetWidth(320)

        _G[s:GetName() .. "Text"]:SetText(label)
        _G[s:GetName() .. "Low"]:SetText(tostring(minV))
        _G[s:GetName() .. "High"]:SetText(tostring(maxV))

        local valText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        valText:SetPoint("LEFT", s, "RIGHT", 12, 0)

        s:SetScript("OnShow", function()
            local v = UiTTSDB[key]; if v == nil then v = default end
            s:SetValue(v); valText:SetText(tostring(v))
        end)
        s:SetScript("OnValueChanged", function(_, value)
            value = tonumber(value) or minV
            value = math.floor((value / step) + 0.5) * step
            if value < minV then value = minV end
            if value > maxV then value = maxV end
            UiTTSDB[key] = value
            valText:SetText(tostring(value))
        end)
        s:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, 1, 1, 1)
            GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        s:SetScript("OnLeave", function() GameTooltip:Hide() end)

        api.y = api.y - 50
        return s
    end

    function api.Button(label, onClick, width)
        widgetIndex = widgetIndex + 1
        local b = CreateFrame("Button", "UiTTSOptBtn" .. widgetIndex, scrollChild, "UIPanelButtonTemplate")
        b:SetSize(width or 180, 24)
        b:SetPoint("TOPLEFT", 16, api.y)
        b:SetText(label)
        b:SetScript("OnClick", onClick)
        api.y = api.y - 32
        return b
    end

    function api.Finalize()
        scrollChild:SetHeight(math.abs(api.y) + 16)
    end

    return api
end

local function RefreshAll()
    for _, fn in ipairs(allRefreshers) do pcall(fn) end
end

local function SetAllReading(value)
    for _, key in ipairs(READ_KEYS) do UiTTSDB[key] = value end
    RefreshAll()
end

-- ========= Voice dropdown =========
local voiceDropdown
local function VoiceLabel()
    if UiTTSDB.voiceID == nil then return L["Automatic (WoW voice setting)"] end
    if C_VoiceChat and C_VoiceChat.GetTtsVoices then
        local voices = C_VoiceChat.GetTtsVoices()
        if type(voices) == "table" then
            for _, v in ipairs(voices) do
                if v.voiceID == UiTTSDB.voiceID then return v.name end
            end
        end
    end
    return L["Automatic (WoW voice setting)"]
end

local function RefreshVoiceDropdown()
    if voiceDropdown and UIDropDownMenu_SetText then
        UIDropDownMenu_SetText(voiceDropdown, VoiceLabel())
    end
end

local function CreateVoiceDropdown(parent, x, y)
    if not (CreateFrame and UIDropDownMenu_Initialize) then return end
    voiceDropdown = CreateFrame("Frame", "UiTTSVoiceDropdown", parent, "UIDropDownMenuTemplate")
    voiceDropdown:SetPoint("TOPLEFT", x - 16, y)

    UIDropDownMenu_Initialize(voiceDropdown, function(_, level)
        -- Automatic entry
        local autoText = L["Automatic (WoW voice setting)"]
        local info = UIDropDownMenu_CreateInfo()
        info.text = autoText
        info.checked = (UiTTSDB.voiceID == nil)
        info.func = function()
            UiTTSDB.voiceID = nil
            UIDropDownMenu_SetText(voiceDropdown, autoText)
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info, level)

        if C_VoiceChat and C_VoiceChat.GetTtsVoices then
            local voices = C_VoiceChat.GetTtsVoices()
            if type(voices) == "table" then
                for _, v in ipairs(voices) do
                    local vid, vname = v.voiceID, v.name
                    local vinfo = UIDropDownMenu_CreateInfo()
                    vinfo.text = vname
                    vinfo.checked = (UiTTSDB.voiceID == vid)
                    vinfo.func = function()
                        UiTTSDB.voiceID = vid
                        UIDropDownMenu_SetText(voiceDropdown, vname)
                        CloseDropDownMenus()
                        -- Preview the chosen voice.
                        if NS and NS.SpeakForced then NS.SpeakForced(L["UiTTS test. One, two, three."]) end
                    end
                    UIDropDownMenu_AddButton(vinfo, level)
                end
            end
        end
    end)
    UIDropDownMenu_SetWidth(voiceDropdown, 260)
    RefreshVoiceDropdown()
    return voiceDropdown
end

-- ========= Panels =========
local function CreateOptionsPanel()
    EnsureDB()

    -- ---- Main: General + Voice ----
    local main = BuildPanel(L["Text-to-Speech"], L["Text-to-Speech"], L["Choose what UiTTS reads aloud (WoW TTS)."])

    main.Checkbox(L["Enable UiTTS"],
        L["Turns the addon on/off entirely. When disabled, no text is read."], "enabled")
    main.Checkbox(L["Interrupt speech when tooltip changes"],
        L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."], "interruptOnNew")
    main.Checkbox(L["Do not repeat identical text"],
        L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."], "skipSameText")

    main.Header(L["Voice output"])

    -- Voice picker label + dropdown
    do
        local lbl = main.child:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        lbl:SetPoint("TOPLEFT", 16, main.y)
        lbl:SetText(L["Voice"])
        main.y = main.y - 20
        CreateVoiceDropdown(main.child, 16, main.y)
        main.y = main.y - 36
    end

    main.Checkbox(L["Use Alternate voice"],
        L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options). Ignored when a specific voice is chosen above."], "useAlternateVoice")
    main.Checkbox(L["Use custom speech rate/volume"],
        L["Overrides WoW's chat TTS rate and volume with the values below. When off, UiTTS follows WoW's Text-to-Speech settings."], "useCustomTTS")
    main.Slider(L["Speech rate (-10 to 10)"],
        L["Speech speed used when 'Use custom speech rate/volume' is enabled. Negative is slower, positive is faster."],
        -10, 10, 1, "ttsRate", 0)
    main.Slider(L["Speech volume (0 to 100)"],
        L["Speech volume used when 'Use custom speech rate/volume' is enabled."],
        0, 100, 5, "ttsVolume", 100)

    main.Header(L["Quick actions"])
    main.Button(L["Enable all reading"], function() SetAllReading(true) end)
    main.Button(L["Disable all reading"], function() SetAllReading(false) end)
    main.Button(L["Test speech (copyable report)"], function()
        SlashCmdList["UITTS"]("test")
    end, 240)

    main.Finalize()

    -- ---- Tooltips ----
    local tips = BuildPanel(L["Tooltips"], L["Tooltips"])
    tips.Header(L["Reading categories"])
    tips.Checkbox(L["Read tooltips (master)"],
        L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."], "readTooltips")
    tips.Checkbox(L["GameTooltip (items / general UI)"],
        L["Reads standard game tooltips when hovering items, abilities, and general UI elements."], "readGameTooltip")
    tips.Checkbox(L["Minimap objects (icons/buttons)"],
        L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."], "readMinimap")
    tips.Checkbox(L["Spellbook"],
        L["Reads tooltips when hovering abilities in the spellbook."], "readSpellbook")
    tips.Checkbox(L["Talent tree"],
        L["Reads tooltips when hovering talents in the character talent tree."], "readTalents")
    tips.Checkbox(L["Profession specializations"],
        L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."], "readProfessions")
    if not NS or NS.HasTradingPost ~= false then
        tips.Checkbox(L["Trading Post / Perks"],
            L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."], "readTradingPost")
    end
    tips.Checkbox(L["Quest rewards (incl. DialogueUI)"],
        L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."], "readQuestRewards")
    tips.Checkbox(L["Quest window (QuestFrame)"],
        L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."], "readQuestFrame")
    tips.Checkbox(L["NPC dialog window (GossipFrame)"],
        L["Reads the NPC greeting text and dialog options when the gossip window opens."], "readGossipFrame")
    tips.Checkbox(L["NPC dialog options on hover"],
        L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."], "readGossipOptionsHover")
    tips.Checkbox(L["Guild Registrar window"],
        L["Reads the greeting and service list of the Guild Master / Petitioner dialog."], "readGuildRegistrar")
    tips.Checkbox(L["DialogueUI option buttons"],
        L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."], "readDialogueUIOptions")
    tips.Checkbox(L["Item links in chat"],
        L["Reads tooltips when clicking item links in chat."], "readItemRef")
    tips.Checkbox(L["Shopping comparison (ShoppingTooltip)"],
        L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."], "readShopping")
    tips.Checkbox(L["Capture dynamic tooltips (scan)"],
        L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."], "scanDynamicTooltips")
    tips.Finalize()

    -- ---- Interface ----
    local ui = BuildPanel(L["Interface / UI buttons"], L["Interface / UI buttons"])
    ui.Checkbox(L["Game menu (ESC)"],
        L["Reads the button label when hovering items in the menu opened by pressing ESC."], "readGameMenu")
    ui.Checkbox(L["Settings buttons and controls"],
        L["Reads the visible label of controls in the Settings panel when hovered."], "readSettingsButtons")
    ui.Checkbox(L["Settings option tooltips"],
        L["Reads the title and description of the tooltip shown when hovering a Settings option."], "readSettingsTooltips")
    ui.Checkbox(L["Read center notifications / Event Toasts"],
        L["Reads center-screen notifications such as completed objectives and event starts."], "readEventToasts")
    ui.Checkbox(L["Read Group Finder banners"],
        L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."], "readPVENewSlice")
    ui.Checkbox(L["Read center screen messages (UIErrors)"],
        L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."], "readUIErrors")
    ui.Checkbox(L["Read raid warnings and boss emotes"],
        L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."], "readRaidWarning")
    ui.Checkbox(L["Read choice options (PlayerChoice)"],
        L["Reads the title and description of an option/card when hovered in the player choice window."], "readPlayerChoice")
    ui.Checkbox(L["Read objective tracker events"],
        L["Reads timed events from the objective tracker, including time remaining and progress collected."], "readScenarioTrackerEvents")
    ui.Checkbox(L["Read information panels"],
        L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."], "readInfoPanels")
    ui.Checkbox(L["Read shop UI"],
        L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."], "readShopUI")
    ui.Finalize()

    -- ---- Chat and events ----
    local chat = BuildPanel(L["Chat and events"], L["Chat and events"])
    chat.Checkbox(L["Read whispers"],
        L["Reads incoming whispers (player and Battle.net), including the sender's name."], "readWhispers")
    chat.Checkbox(L["Read party chat"],
        L["Reads messages in party chat, including the sender's name."], "readParty")
    chat.Checkbox(L["Read say"],
        L["Reads nearby 'say' messages, including the speaker's name."], "readSay")
    chat.Checkbox(L["Read guild chat"],
        L["Reads guild chat messages, including the sender's name."], "readGuild")
    chat.Checkbox(L["Read yell"],
        L["Reads nearby 'yell' messages, including the speaker's name."], "readYell")
    chat.Checkbox(L["Read loot messages"],
        L["Reads loot messages such as items and money you receive."], "readLoot")
    chat.Checkbox(L["Read target changes"],
        L["Announces the name and level of your target whenever it changes."], "readTargetChange")
    chat.Finalize()

    -- ---- Experience & performance ----
    local perf = BuildPanel(L["Experience & performance"], L["Experience & performance"])
    perf.Header(L["Experience / leveling"])
    perf.Checkbox(L["Read XP gains"],
        L["Reads how much experience the player gains, summarised in short batches."], "readXPGain")
    perf.Checkbox(L["Read level-ups"],
        L["Announces the new level when the player levels up."], "readLevelUp")
    perf.Header(L["Stability / performance"])
    perf.Slider(L["Debounce (sec)"],
        L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."],
        0, 0.5, 0.02, "debounceDelay", 0.08)
    perf.Slider(L["Minimum global interval (sec)"],
        L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."],
        0, 1, 0.05, "minInterval", 0.15)
    perf.Slider(L["Scan interval (sec)"],
        L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."],
        0.2, 5.0, 0.2, "scanInterval", 1.0)
    perf.Slider(L["Per-owner time lock (sec) (optional)"],
        L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."],
        0, 10, 0.5, "lockSameOwnerFor", 0)
    perf.Slider(L["Max lines read per tooltip"],
        L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."],
        1, 30, 1, "maxLines", 12)
    perf.Checkbox(L["Debug log (UI Reader)"],
        L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."], "debugUIReader")
    perf.Finalize()

    -- Refresh the voice dropdown whenever the main panel is shown.
    main.panel:SetScript("OnShow", RefreshVoiceDropdown)

    -- ---- Register ----
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local rootCategory = _G.AbleCraft_OptionsCategory
        local category
        if rootCategory and Settings.RegisterCanvasLayoutSubcategory then
            local ok, sub = pcall(Settings.RegisterCanvasLayoutSubcategory, rootCategory, main.panel, main.panel.name)
            if ok and sub then category = sub end
        end
        if not category then
            category = Settings.RegisterCanvasLayoutCategory(main.panel, main.panel.name)
            Settings.RegisterAddOnCategory(category)
        end
        _G.UiTTS_OptionsCategoryID = (category.GetID and category:GetID()) or category.ID
        _G.UiTTS_OptionsCategory = category

        local function AddSub(p)
            local parentCat = category
            local ok = pcall(function() Settings.RegisterCanvasLayoutSubcategory(parentCat, p.panel, p.panel.name) end)
            if not ok and rootCategory then
                pcall(function() Settings.RegisterCanvasLayoutSubcategory(rootCategory, p.panel, p.panel.name) end)
            end
        end
        AddSub(tips)
        AddSub(ui)
        AddSub(chat)
        AddSub(perf)
    elseif InterfaceOptions_AddCategory then
        main.panel.parent = "AbleCraft"
        _G.UiTTS_OptionsPanel = main.panel
        InterfaceOptions_AddCategory(main.panel)
        _G.UiTTS_OptionsCategoryID = nil
    end
end

CreateOptionsPanel()
