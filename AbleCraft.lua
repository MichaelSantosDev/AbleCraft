-- AbleCraft.lua (WoW Forever Beta 1.60.x / modern Settings API)
--
-- Root namespace, SavedVariables synchronization (AbleCraftDB <-> UiTTSDB),
-- and main "AbleCraft" Settings category. Modules such as Text-to-Speech (UiTTS)
-- attach their options as subcategories under AbleCraft.

local ADDON_NAME, NS = ...
AbleCraft_NS = NS
AbleCraft_L  = UiTTS_L

local L = UiTTS_L

-- Synchronize AbleCraftDB and UiTTSDB so existing saved settings from UiTTSDB
-- carry over seamlessly while AbleCraftDB persists all settings.
local function SyncSavedVariables()
    if type(AbleCraftDB) ~= "table" then AbleCraftDB = {} end
    if type(UiTTSDB) ~= "table" then UiTTSDB = {} end

    -- Migrate any existing keys from UiTTSDB into AbleCraftDB without overwriting
    for k, v in pairs(UiTTSDB) do
        if AbleCraftDB[k] == nil then
            AbleCraftDB[k] = v
        end
    end

    -- Share the same table reference so reads/writes through either global stay in sync
    UiTTSDB = AbleCraftDB
    NS.db = AbleCraftDB
end

SyncSavedVariables()

-- Build the root "AbleCraft" panel in Game Settings -> AddOns
local function CreateRootPanel()
    local panel = CreateFrame("Frame", "AbleCraftRootPanel", UIParent)
    panel.name = "AbleCraft"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("AbleCraft")

    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", 16, -40)
    sub:SetWidth(560)
    sub:SetJustifyH("LEFT")
    sub:SetText(L["Accessibility suite for World of Warcraft."])

    local ttsBtn = CreateFrame("Button", "AbleCraftOpenTTSBtn", panel, "UIPanelButtonTemplate")
    ttsBtn:SetSize(220, 26)
    ttsBtn:SetPoint("TOPLEFT", 16, -80)
    ttsBtn:SetText(L["Open Text-to-Speech"])
    ttsBtn:SetScript("OnClick", function()
        if UiTTS_NS and UiTTS_NS.OpenConfig then
            UiTTS_NS.OpenConfig()
        end
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        _G.AbleCraft_OptionsCategory = category
        _G.AbleCraft_OptionsCategoryID = (category.GetID and category:GetID()) or category.ID
    elseif InterfaceOptions_AddCategory then
        _G.AbleCraft_OptionsPanel = panel
        InterfaceOptions_AddCategory(panel)
    end
end

CreateRootPanel()

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_NAME then
        SyncSavedVariables()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
