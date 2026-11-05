if GetLocale() ~= "zhTW" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS：已啟用。"
L["UiTTS: disabled."] = "UiTTS：已停用。"
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS：請開啟 設定 -> 插件 -> UiTTS。"
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS 已載入。使用 /uitts config 開啟選項。"

L["00:%02d:%02d time remaining"] = "00:%02d:%02d 剩餘時間"
L["%d of %d collected."] = "已蒐集 %d / %d。"
L["Read quest again (R)"] = "重新朗讀任務 (R)"
L["Read dialog again (R)"] = "重新朗讀對話 (R)"
L["Equipped:"] = "已裝備："

L["Gained %d XP."] = "獲得 %d 經驗。"
L["Level up! Now level %d."] = "升等！目前等級 %d。"

L["Experience / leveling"] = "經驗 / 升等"
L["Read XP gains"] = "朗讀經驗獲得"
L["Reads how much experience the player gains, summarised in short batches."] =
    "朗讀玩家獲得的經驗，依短時間區段彙整。"
L["Read level-ups"] = "朗讀升等"
L["Announces the new level when the player levels up."] =
    "玩家升等時朗讀新的等級。"

L["Choose what UiTTS reads aloud (WoW TTS)."] = "選擇 UiTTS 要朗讀的內容（魔獸 TTS）。"

L["Reading categories"] = "朗讀分類"
L["Interface / UI buttons"] = "介面 / UI 按鈕"
L["Stability / performance"] = "穩定性 / 效能"

L["Enable UiTTS"] = "啟用 UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "完全開啟或關閉插件。關閉後不會朗讀任何文字。"

L["Interrupt speech when tooltip changes"] = "切換提示時打斷朗讀"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "停止目前朗讀並立刻開始朗讀新的提示，不等待前一段結束。"

L["Do not repeat identical text"] = "不重複相同文字"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "若最終文字與同一提示上次朗讀的內容相同，則抑制重複。"

L["Use Alternate voice"] = "使用替代語音"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "使用替代 TTS 語音而非標準語音（需在魔獸的語音選項中設定替代語音）。"

L["Read tooltips (master)"] = "朗讀提示（總開關）"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "提示朗讀的總開關。關閉後不論下方各項設定為何，所有提示皆不會朗讀。"

L["GameTooltip (items / general UI)"] = "GameTooltip（物品 / 一般 UI）"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "在物品、技能與一般 UI 元素上懸停時朗讀遊戲的標準提示。"

L["Minimap objects (icons/buttons)"] = "小地圖物件（圖示/按鈕）"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "朗讀小地圖圖示與按鈕的提示。GameTooltip 關閉但你仍想聽到小地圖圖示時很實用。"

L["Spellbook"] = "法術書"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "在法術書中懸停技能時朗讀提示。"

L["Talent tree"] = "天賦樹"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "在角色天賦樹中懸停天賦時朗讀提示。"

L["Profession specializations"] = "專業專精"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "在專業畫面朗讀專精提示，包括專精與解鎖節點。"

L["Trading Post / Perks"] = "貿易站 / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "懸停獎勵與物品時朗讀貿易站與 Perks 計畫的提示。"

L["Quest rewards (incl. DialogueUI)"] = "任務獎勵（含 DialogueUI）"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "在遊戲原生介面與 DialogueUI 等插件中朗讀任務獎勵提示。"

L["Quest window (QuestFrame)"] = "任務視窗（QuestFrame）"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "開啟魔獸預設任務視窗時朗讀描述與目標。使用喇叭圖示或按 R 重新朗讀。"

L["NPC dialog window (GossipFrame)"] = "NPC 對話視窗（GossipFrame）"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "開啟對話視窗時朗讀 NPC 招呼語與對話選項。"

L["Guild Registrar window"] = "公會註冊員視窗"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "朗讀公會管理員/請願者對話的問候語與服務列表。"

L["DialogueUI option buttons"] = "DialogueUI 選項按鈕"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "懸停 DialogueUI 的對話 / 接受 / 離開按鈕時朗讀其標籤。"

L["Item links in chat"] = "聊天中的物品連結"
L["Reads tooltips when clicking item links in chat."] =
    "點擊聊天中的物品連結時朗讀提示。"

L["Shopping comparison (ShoppingTooltip)"] = "比較購物（ShoppingTooltip）"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "按住 Shift 懸停物品時朗讀比較提示，以便聽到屬性差異。"

L["Capture dynamic tooltips (scan)"] = "捕捉動態提示（掃描）"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "搜尋並註冊由插件在魔獸標準流程之外建立的提示。某些插件（如 DialogueUI）需要此選項。"

L["Game menu (ESC)"] = "遊戲選單（ESC）"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "懸停以 ESC 開啟的選單中的項目時朗讀按鈕標籤。"

L["Settings buttons and controls"] = "設定中的按鈕與控制項"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "懸停設定面板中的控制項時朗讀其可見標籤。"

L["Settings option tooltips"] = "設定選項提示"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "懸停設定選項時朗讀所顯示提示的標題與描述。"

L["Read center notifications / Event Toasts"] = "朗讀畫面中央通知 / Event Toast"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "朗讀畫面中央的通知，例如完成目標與事件開始。"

L["Read center screen messages (UIErrors)"] = "朗讀畫面中央訊息（UIErrors）"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "朗讀畫面中央顯示的簡短訊息，例如錯誤、警告與不可用動作。"

L["Read choice options (PlayerChoice)"] = "朗讀選項（PlayerChoice）"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "在玩家選擇視窗懸停選項/卡片時朗讀其標題與描述。"

L["Read objective tracker events"] = "朗讀目標追蹤事件"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "朗讀目標追蹤器的計時事件，包括剩餘時間與已蒐集進度。"

L["Read information panels"] = "朗讀資訊面板"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "朗讀遊戲視窗中的描述面板，例如同盟種族描述與其他詳情畫面。懸停面板內容區時朗讀。"

L["Read shop UI"] = "朗讀商城介面"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "懸停遊戲內商城的商品與動作按鈕時朗讀可見的文字與按鈕，包括名稱、描述、價格以及「詳細資料」、「購買」等按鈕。"

L["Read Group Finder banners"] = "朗讀組隊查詢器橫幅"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "組隊查詢器視窗出現「新賽季」/「新內容」橫幅時朗讀。"

L["Debug log (UI Reader)"] = "除錯紀錄（UI Reader）"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "在聊天視窗輸出有關按鈕與 UI 提示朗讀的除錯資訊。僅在診斷問題時使用。"

L["Debounce (sec)"] = "防抖動（秒）"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "提示出現後開始朗讀前的等待時間。值較高可減少快速移動滑鼠時的誤讀。"

L["Minimum global interval (sec)"] = "全域最小間隔（秒）"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "兩次連續朗讀之間的最短時間。可避免提示快速變化時語音重疊。"

L["Scan interval (sec)"] = "掃描間隔（秒）"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "插件掃描其他插件建立的動態提示的頻率。值越低偵測越快但耗用更多 CPU。"

L["Per-owner time lock (sec) (optional)"] = "依擁有者時間鎖（秒）（選用）"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "朗讀提示後，在此期間忽略同一擁有者的新提示。0 表示停用。有助於避免事件頻繁的 UI 重複朗讀。"

L["Max lines read per tooltip"] = "每條提示最大朗讀行數"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "限制每條提示朗讀的文字行數。行數較多的提示（例如複雜物品）可能被截斷以縮短朗讀。"

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "開啟對話視窗時朗讀 NPC 招呼語與對話選項。使用喇叭圖示或按 R 重新朗讀。"

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "朗讀團隊警告與首領動作"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "朗讀螢幕上方中央顯示的大字警告，例如團隊警告、首領動作與事件公告。"

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "滑鼠停留時朗讀對話選項"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "當滑鼠停留在對話視窗的選項上時朗讀該選項，包括由 DMHC 等外觀插件繪製的選項。"
