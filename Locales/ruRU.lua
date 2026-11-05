if GetLocale() ~= "ruRU" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS: включён."
L["UiTTS: disabled."] = "UiTTS: выключен."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS: Откройте Настройки -> Аддоны -> UiTTS."
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS загружен. Используйте /uitts config, чтобы открыть настройки."

L["00:%02d:%02d time remaining"] = "00:%02d:%02d оставшееся время"
L["%d of %d collected."] = "%d из %d собрано."
L["Read quest again (R)"] = "Перечитать задание (R)"
L["Read dialog again (R)"] = "Перечитать диалог (R)"
L["Equipped:"] = "Экипировано:"

L["Gained %d XP."] = "Получено %d опыта."
L["Level up! Now level %d."] = "Новый уровень! Теперь уровень %d."

L["Experience / leveling"] = "Опыт / повышение уровня"
L["Read XP gains"] = "Озвучивать получение опыта"
L["Reads how much experience the player gains, summarised in short batches."] =
    "Озвучивает количество полученного опыта, объединяя в короткие пакеты."
L["Read level-ups"] = "Озвучивать повышение уровня"
L["Announces the new level when the player levels up."] =
    "Объявляет новый уровень при повышении."

L["Choose what UiTTS reads aloud (WoW TTS)."] = "Выберите, что UiTTS должен озвучивать (TTS WoW)."

L["Reading categories"] = "Категории чтения"
L["Interface / UI buttons"] = "Интерфейс / кнопки UI"
L["Stability / performance"] = "Стабильность / производительность"

L["Enable UiTTS"] = "Включить UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "Полностью включает или выключает аддон. Когда выключен, текст не озвучивается."

L["Interrupt speech when tooltip changes"] = "Прерывать речь при смене подсказки"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "Останавливает текущую речь и сразу начинает озвучивать новую подсказку, не дожидаясь окончания предыдущей."

L["Do not repeat identical text"] = "Не повторять одинаковый текст"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "Если итоговый текст совпадает с последним озвученным для той же подсказки, повтор пропускается."

L["Use Alternate voice"] = "Использовать альтернативный голос"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "Использует альтернативный голос TTS вместо стандартного (требуется настроенный альтернативный голос в параметрах голоса WoW)."

L["Read tooltips (master)"] = "Озвучивать подсказки (общее)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "Главный переключатель чтения подсказок. При отключении подавляет все подсказки независимо от отдельных опций ниже."

L["GameTooltip (items / general UI)"] = "GameTooltip (предметы / общий UI)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "Озвучивает стандартные подсказки игры при наведении на предметы, способности и общие элементы интерфейса."

L["Minimap objects (icons/buttons)"] = "Объекты миникарты (значки/кнопки)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "Озвучивает подсказки значков и кнопок миникарты. Полезно, когда GameTooltip выключен, но вы хотите слышать значки карты."

L["Spellbook"] = "Книга заклинаний"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "Озвучивает подсказки при наведении на способности в книге заклинаний."

L["Talent tree"] = "Дерево талантов"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "Озвучивает подсказки при наведении на таланты в дереве талантов персонажа."

L["Profession specializations"] = "Специализации профессий"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "Озвучивает подсказки специализаций в окне профессий, включая узлы специализации и разблокировки."

L["Trading Post / Perks"] = "Торговый пост / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "Озвучивает подсказки Торгового поста и программы Perks при наведении на награды и предметы."

L["Quest rewards (incl. DialogueUI)"] = "Награды за задания (включая DialogueUI)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "Озвучивает подсказки наград за задания в стандартных интерфейсах игры и в аддонах вроде DialogueUI."

L["Quest window (QuestFrame)"] = "Окно задания (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "Озвучивает описание и цели стандартного окна задания при открытии. Используйте значок динамика или нажмите R, чтобы перезапустить чтение."

L["NPC dialog window (GossipFrame)"] = "Окно диалога NPC (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "Озвучивает приветствие NPC и варианты диалога при открытии окна общения."

L["Guild Registrar window"] = "Окно гильдейского секретаря"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "Зачитывает приветствие и список услуг из диалога гильдейского мастера / петиционера."

L["DialogueUI option buttons"] = "Кнопки вариантов DialogueUI"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "Озвучивает подписи кнопок общения / принять / выйти DialogueUI при наведении."

L["Item links in chat"] = "Ссылки на предметы в чате"
L["Reads tooltips when clicking item links in chat."] =
    "Озвучивает подсказки при клике по ссылкам предметов в чате."

L["Shopping comparison (ShoppingTooltip)"] = "Сравнение покупок (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "Озвучивает подсказки сравнения, появляющиеся при удерживании Shift над предметом, чтобы можно было услышать разницу в характеристиках."

L["Capture dynamic tooltips (scan)"] = "Захватывать динамические подсказки (скан)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "Ищет и регистрирует подсказки, созданные аддонами вне стандартного потока WoW. Требуется для некоторых аддонов, например DialogueUI."

L["Game menu (ESC)"] = "Игровое меню (ESC)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "Озвучивает подпись кнопки при наведении в меню, открываемом клавишей ESC."

L["Settings buttons and controls"] = "Кнопки и элементы Настроек"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "Озвучивает видимую подпись элементов панели Настроек при наведении."

L["Settings option tooltips"] = "Подсказки параметров в Настройках"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "Озвучивает заголовок и описание подсказки, показанной при наведении на параметр в Настройках."

L["Read center notifications / Event Toasts"] = "Озвучивать центральные уведомления / Event Toasts"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "Озвучивает уведомления в центре экрана, такие как завершённые цели и начала событий."

L["Read center screen messages (UIErrors)"] = "Озвучивать сообщения в центре экрана (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "Озвучивает короткие сообщения в центре экрана, такие как ошибки, предупреждения и недоступные действия."

L["Read choice options (PlayerChoice)"] = "Озвучивать варианты выбора (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "Озвучивает заголовок и описание варианта/карточки при наведении в окне выбора игрока."

L["Read objective tracker events"] = "Озвучивать события отслеживания целей"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "Озвучивает события по времени из отслеживания целей, включая оставшееся время и прогресс."

L["Read information panels"] = "Озвучивать информационные панели"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "Озвучивает описательные панели в окнах игры, например описание союзных рас и другие экраны подробностей. Текст читается при наведении на область содержимого панели."

L["Read shop UI"] = "Озвучивать интерфейс магазина"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "Озвучивает видимые тексты и кнопки внутриигрового магазина при наведении на товары и кнопки действий, включая имя, описание, цену и кнопки вроде «Подробнее» и «Купить»."

L["Read Group Finder banners"] = "Озвучивать баннеры Поиска группы"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "Озвучивает баннер «Новый сезон» / «Новый контент» в окне Поиска группы при его появлении."

L["Debug log (UI Reader)"] = "Журнал отладки (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "Выводит в чат отладочную информацию о чтении кнопок и подсказок интерфейса. Используйте только для диагностики."

L["Debounce (sec)"] = "Задержка (сек)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "Время ожидания после появления подсказки перед началом чтения. Увеличение уменьшает случайные чтения при быстрых движениях мыши."

L["Minimum global interval (sec)"] = "Минимальный глобальный интервал (сек)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "Минимальное время между двумя последовательными чтениями. Предотвращает наложение речи при быстрой смене подсказок."

L["Scan interval (sec)"] = "Интервал сканирования (сек)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "Как часто аддон ищет динамические подсказки других аддонов. Меньшие значения обнаруживают быстрее, но используют больше CPU."

L["Per-owner time lock (sec) (optional)"] = "Блокировка по владельцу (сек) (опционально)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "После чтения подсказки игнорирует новые подсказки того же владельца в течение этого времени. 0 — отключить. Помогает избежать повторов в UI с частыми событиями."

L["Max lines read per tooltip"] = "Макс. строк на подсказку"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "Ограничивает количество читаемых строк на подсказку. Длинные подсказки (например, сложные предметы) могут быть сокращены."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "Озвучивает приветствие NPC и варианты диалога при открытии окна общения. Используйте значок динамика или нажмите R, чтобы перезапустить чтение."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "Озвучивать предупреждения рейда и реплики боссов"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "Озвучивает крупные предупреждения в верхней центральной части экрана: предупреждения рейда, реплики боссов и объявления событий."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "Варианты диалога NPC при наведении"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "Озвучивает каждый вариант диалога в окне общения при наведении мыши, включая варианты, отрисованные скинами вроде DMHC."
