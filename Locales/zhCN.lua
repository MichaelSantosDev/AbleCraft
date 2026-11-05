if GetLocale() ~= "zhCN" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS：已启用。"
L["UiTTS: disabled."] = "UiTTS：已禁用。"
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS：请打开 设置 -> 插件 -> UiTTS。"
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS 已加载。使用 /uitts config 打开选项。"

L["00:%02d:%02d time remaining"] = "00:%02d:%02d 剩余时间"
L["%d of %d collected."] = "已收集 %d / %d。"
L["Read quest again (R)"] = "重新朗读任务 (R)"
L["Read dialog again (R)"] = "重新朗读对话 (R)"
L["Equipped:"] = "已装备："

L["Gained %d XP."] = "获得 %d 经验。"
L["Level up! Now level %d."] = "升级！现在等级 %d。"

L["Experience / leveling"] = "经验 / 升级"
L["Read XP gains"] = "朗读经验获得"
L["Reads how much experience the player gains, summarised in short batches."] =
    "朗读玩家获得的经验，按短时间区段汇总。"
L["Read level-ups"] = "朗读升级"
L["Announces the new level when the player levels up."] =
    "玩家升级时朗读新的等级。"

L["Choose what UiTTS reads aloud (WoW TTS)."] = "选择 UiTTS 要朗读的内容（魔兽 TTS）。"

L["Reading categories"] = "朗读类别"
L["Interface / UI buttons"] = "界面 / UI 按钮"
L["Stability / performance"] = "稳定性 / 性能"

L["Enable UiTTS"] = "启用 UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "完全开启或关闭插件。关闭后不会朗读任何文本。"

L["Interrupt speech when tooltip changes"] = "切换提示时打断朗读"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "停止当前朗读并立刻开始朗读新的提示，不等待上一段结束。"

L["Do not repeat identical text"] = "不重复相同文本"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "如果最终文本与同一提示上次朗读的内容相同，则抑制重复。"

L["Use Alternate voice"] = "使用备用语音"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "使用备用 TTS 语音而非标准语音（需要在魔兽的语音选项中配置备用语音）。"

L["Read tooltips (master)"] = "朗读提示（总开关）"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "提示朗读的总开关。关闭后无论下方各项设置如何，所有提示均不会朗读。"

L["GameTooltip (items / general UI)"] = "GameTooltip（物品 / 通用 UI）"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "悬停物品、技能和通用 UI 元素时朗读游戏的标准提示。"

L["Minimap objects (icons/buttons)"] = "小地图对象（图标/按钮）"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "朗读小地图图标和按钮的提示。当 GameTooltip 关闭但你仍想听到小地图图标时很有用。"

L["Spellbook"] = "法术书"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "悬停法术书中的技能时朗读提示。"

L["Talent tree"] = "天赋树"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "悬停角色天赋树中的天赋时朗读提示。"

L["Profession specializations"] = "专业专精"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "在专业界面朗读专精提示，包括专精与解锁节点。"

L["Trading Post / Perks"] = "贸易站 / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "悬停奖励和物品时朗读贸易站与 Perks 计划的提示。"

L["Quest rewards (incl. DialogueUI)"] = "任务奖励（含 DialogueUI）"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "在游戏原生界面以及 DialogueUI 等插件中朗读任务奖励提示。"

L["Quest window (QuestFrame)"] = "任务窗口（QuestFrame）"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "打开魔兽默认任务窗口时朗读描述和目标。使用扬声器图标或按 R 重新朗读。"

L["NPC dialog window (GossipFrame)"] = "NPC 对话窗口（GossipFrame）"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "打开对话窗口时朗读 NPC 的问候语和对话选项。"

L["Guild Registrar window"] = "公会注册员窗口"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "朗读公会管理员/请愿者对话的问候语和服务列表。"

L["DialogueUI option buttons"] = "DialogueUI 选项按钮"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "悬停 DialogueUI 的对话 / 接受 / 退出按钮时朗读其标签。"

L["Item links in chat"] = "聊天中的物品链接"
L["Reads tooltips when clicking item links in chat."] =
    "点击聊天中的物品链接时朗读提示。"

L["Shopping comparison (ShoppingTooltip)"] = "比较购物（ShoppingTooltip）"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "按住 Shift 悬停物品时朗读比较提示，便于听到属性差异。"

L["Capture dynamic tooltips (scan)"] = "捕获动态提示（扫描）"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "搜索并注册由插件在魔兽标准流程之外创建的提示。某些插件（如 DialogueUI）需要此选项。"

L["Game menu (ESC)"] = "游戏菜单（ESC）"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "悬停按 ESC 打开的菜单中的项目时朗读按钮标签。"

L["Settings buttons and controls"] = "设置中的按钮和控件"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "悬停设置面板中的控件时朗读其可见标签。"

L["Settings option tooltips"] = "设置选项提示"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "悬停设置选项时朗读所显示提示的标题与描述。"

L["Read center notifications / Event Toasts"] = "朗读屏幕中央通知 / Event Toast"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "朗读屏幕中央的通知，例如完成目标和事件开始。"

L["Read center screen messages (UIErrors)"] = "朗读屏幕中央消息（UIErrors）"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "朗读屏幕中央显示的简短消息，例如错误、警告和不可用动作。"

L["Read choice options (PlayerChoice)"] = "朗读选项（PlayerChoice）"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "在玩家选择窗口悬停某个选项/卡片时朗读其标题和描述。"

L["Read objective tracker events"] = "朗读目标追踪事件"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "朗读目标追踪器中的计时事件，包括剩余时间和已收集进度。"

L["Read information panels"] = "朗读信息面板"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "朗读游戏窗口中的描述面板，例如同盟种族描述及其他详情界面。悬停面板的内容区域时朗读。"

L["Read shop UI"] = "朗读商城界面"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "悬停游戏内商城的商品和操作按钮时朗读可见的文本与按钮，包括名称、描述、价格以及“详情”“购买”等按钮。"

L["Read Group Finder banners"] = "朗读队伍查找器横幅"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "队伍查找器窗口出现“新赛季”/“新内容”横幅时朗读它。"

L["Debug log (UI Reader)"] = "调试日志（UI Reader）"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "在聊天框中输出有关按钮和 UI 提示朗读的调试信息。仅在排查问题时使用。"

L["Debounce (sec)"] = "防抖（秒）"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "提示出现后开始朗读前的等待时间。较高的值可减少快速移动鼠标时的误读。"

L["Minimum global interval (sec)"] = "全局最小间隔（秒）"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "两次连续朗读之间的最短时间。可防止提示快速变化时语音重叠。"

L["Scan interval (sec)"] = "扫描间隔（秒）"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "插件扫描其他插件创建的动态提示的频率。值越低检测越快但占用更多 CPU。"

L["Per-owner time lock (sec) (optional)"] = "按所有者时间锁（秒）（可选）"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "朗读某条提示后，在此时长内忽略来自同一所有者的新提示。0 表示禁用。有助于避免在事件频繁的 UI 中重复。"

L["Max lines read per tooltip"] = "每条提示最大朗读行数"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "限制每条提示朗读的文本行数。行数较多的提示（例如复杂物品）可能会被截断以缩短朗读。"

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "打开对话窗口时朗读 NPC 的问候语和对话选项。使用扬声器图标或按 R 重新朗读。"

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "朗读团队警告和首领动作"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "朗读屏幕上方中央显示的大字警告，例如团队警告、首领动作和事件公告。"

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "鼠标悬停时朗读对话选项"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "当鼠标悬停在对话窗口的选项上时朗读该选项，包括由 DMHC 等皮肤绘制的选项。"
