if GetLocale() ~= "koKR" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS: 활성화됨."
L["UiTTS: disabled."] = "UiTTS: 비활성화됨."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS: 설정 -> 애드온 -> UiTTS 를 여세요."
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS 가 로드되었습니다. /uitts config 명령으로 옵션을 여세요."

L["00:%02d:%02d time remaining"] = "00:%02d:%02d 남은 시간"
L["%d of %d collected."] = "%d / %d 수집됨."
L["Read quest again (R)"] = "퀘스트 다시 읽기 (R)"
L["Read dialog again (R)"] = "대화 다시 읽기 (R)"
L["Equipped:"] = "착용 중:"

L["Gained %d XP."] = "경험치 %d 획득."
L["Level up! Now level %d."] = "레벨 업! 현재 %d 레벨."

L["Experience / leveling"] = "경험치 / 레벨업"
L["Read XP gains"] = "경험치 획득 읽기"
L["Reads how much experience the player gains, summarised in short batches."] =
    "획득한 경험치를 짧은 간격으로 묶어서 읽어줍니다."
L["Read level-ups"] = "레벨업 읽기"
L["Announces the new level when the player levels up."] =
    "캐릭터가 레벨업할 때 새 레벨을 알려줍니다."

L["Choose what UiTTS reads aloud (WoW TTS)."] = "UiTTS 가 음성으로 읽을 항목을 선택하세요 (WoW TTS)."

L["Reading categories"] = "읽기 분류"
L["Interface / UI buttons"] = "인터페이스 / UI 버튼"
L["Stability / performance"] = "안정성 / 성능"

L["Enable UiTTS"] = "UiTTS 사용"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "애드온 전체를 켜고 끕니다. 비활성화하면 어떤 텍스트도 읽지 않습니다."

L["Interrupt speech when tooltip changes"] = "툴팁 변경 시 음성 중단"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "이전 읽기가 끝나기를 기다리지 않고 현재 음성을 멈춘 뒤 새 툴팁을 즉시 읽기 시작합니다."

L["Do not repeat identical text"] = "동일한 텍스트 반복 금지"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "동일한 툴팁에서 최종 텍스트가 마지막으로 읽은 텍스트와 같다면 반복을 억제합니다."

L["Use Alternate voice"] = "대체 음성 사용"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "표준 음성 대신 대체 TTS 음성을 사용합니다 (WoW 음성 옵션에 대체 음성이 설정되어 있어야 합니다)."

L["Read tooltips (master)"] = "툴팁 읽기 (마스터)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "툴팁 읽기 마스터 토글입니다. 끄면 아래의 개별 설정과 상관없이 모든 툴팁이 억제됩니다."

L["GameTooltip (items / general UI)"] = "GameTooltip (아이템 / 일반 UI)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "아이템, 주문, 일반 UI 요소 위에 마우스를 올릴 때 게임의 표준 툴팁을 읽습니다."

L["Minimap objects (icons/buttons)"] = "미니맵 오브젝트 (아이콘/버튼)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "미니맵 아이콘과 버튼의 툴팁을 읽습니다. GameTooltip 을 끈 상태에서도 미니맵 아이콘을 듣고 싶을 때 유용합니다."

L["Spellbook"] = "주문서"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "주문서에서 주문 위에 마우스를 올릴 때 툴팁을 읽습니다."

L["Talent tree"] = "특성 트리"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "캐릭터 특성 트리에서 특성 위에 마우스를 올릴 때 툴팁을 읽습니다."

L["Profession specializations"] = "전문기술 전문화"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "전문기술 화면에서 전문화 및 해금 노드를 포함한 전문화 툴팁을 읽습니다."

L["Trading Post / Perks"] = "교역소 / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "보상과 아이템 위에 마우스를 올릴 때 교역소와 Perks 프로그램의 툴팁을 읽습니다."

L["Quest rewards (incl. DialogueUI)"] = "퀘스트 보상 (DialogueUI 포함)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "게임 기본 UI 및 DialogueUI 같은 애드온의 퀘스트 보상 툴팁을 읽습니다."

L["Quest window (QuestFrame)"] = "퀘스트 창 (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "WoW 기본 퀘스트 창이 열릴 때 설명과 목표를 읽습니다. 스피커 아이콘이나 R 키로 다시 읽을 수 있습니다."

L["NPC dialog window (GossipFrame)"] = "NPC 대화 창 (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "대화 창이 열릴 때 NPC 인사말과 대화 옵션을 읽습니다."

L["Guild Registrar window"] = "길드 등록관 창"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "길드 마스터 / 청원자 대화의 인사말과 서비스 목록을 읽어줍니다."

L["DialogueUI option buttons"] = "DialogueUI 옵션 버튼"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "DialogueUI 의 대화 / 수락 / 나가기 버튼 위에 마우스를 올릴 때 레이블을 읽습니다."

L["Item links in chat"] = "대화창의 아이템 링크"
L["Reads tooltips when clicking item links in chat."] =
    "대화창에서 아이템 링크를 클릭할 때 툴팁을 읽습니다."

L["Shopping comparison (ShoppingTooltip)"] = "쇼핑 비교 (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "아이템 위에서 Shift 를 누른 동안 표시되는 비교 툴팁을 읽어 능력치 차이를 들을 수 있도록 합니다."

L["Capture dynamic tooltips (scan)"] = "동적 툴팁 캡처 (스캔)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "WoW 의 표준 흐름 밖에서 애드온이 만든 툴팁을 검색하고 등록합니다. DialogueUI 같은 일부 애드온에 필요합니다."

L["Game menu (ESC)"] = "게임 메뉴 (ESC)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "ESC 로 열린 메뉴에서 항목 위에 마우스를 올릴 때 버튼 레이블을 읽습니다."

L["Settings buttons and controls"] = "설정 버튼 및 컨트롤"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "설정 패널의 컨트롤 위에 마우스를 올릴 때 표시된 레이블을 읽습니다."

L["Settings option tooltips"] = "설정 옵션 툴팁"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "설정 옵션 위에 마우스를 올릴 때 표시되는 툴팁의 제목과 설명을 읽습니다."

L["Read center notifications / Event Toasts"] = "화면 중앙 알림 / Event Toast 읽기"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "완료된 목표나 이벤트 시작과 같은 화면 중앙 알림을 읽습니다."

L["Read center screen messages (UIErrors)"] = "화면 중앙 메시지 읽기 (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "오류, 경고, 사용 불가 동작과 같이 화면 중앙에 표시되는 짧은 메시지를 읽습니다."

L["Read choice options (PlayerChoice)"] = "선택지 읽기 (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "플레이어 선택 창에서 옵션/카드 위에 마우스를 올릴 때 제목과 설명을 읽습니다."

L["Read objective tracker events"] = "목표 추적기 이벤트 읽기"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "남은 시간과 수집 진행 상황을 포함해 목표 추적기의 시간제 이벤트를 읽습니다."

L["Read information panels"] = "정보 패널 읽기"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "동맹 종족 설명과 같은 게임 창의 설명 패널 및 기타 상세 화면을 읽습니다. 패널의 본문 영역에 마우스를 올렸을 때 읽습니다."

L["Read shop UI"] = "상점 UI 읽기"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "인게임 상점에서 상품과 동작 버튼 위에 마우스를 올릴 때 이름, 설명, 가격, '자세히' '구매' 같은 버튼을 포함한 표시된 텍스트와 버튼을 읽습니다."

L["Read Group Finder banners"] = "파티 찾기 배너 읽기"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "파티 찾기 창에 표시되는 '새 시즌' / '새 콘텐츠' 배너를 읽습니다."

L["Debug log (UI Reader)"] = "디버그 로그 (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "버튼과 UI 툴팁 읽기에 대한 디버그 정보를 대화창에 출력합니다. 문제 진단 용도로만 사용하세요."

L["Debounce (sec)"] = "디바운스 (초)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "툴팁이 나타난 뒤 읽기 시작까지의 대기 시간입니다. 값을 높이면 마우스를 빠르게 움직일 때의 우발적 읽기를 줄입니다."

L["Minimum global interval (sec)"] = "최소 전체 간격 (초)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "두 번의 연속 읽기 사이의 최소 시간입니다. 툴팁이 빠르게 바뀔 때 음성이 겹치는 것을 방지합니다."

L["Scan interval (sec)"] = "스캔 간격 (초)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "다른 애드온이 만든 동적 툴팁을 얼마나 자주 스캔할지 결정합니다. 값이 낮을수록 빠르게 감지하지만 CPU 사용이 늘어납니다."

L["Per-owner time lock (sec) (optional)"] = "소유자별 시간 잠금 (초) (선택)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "툴팁을 읽은 뒤 동일한 소유자의 새 툴팁을 이 시간 동안 무시합니다. 0 이면 비활성화됩니다. 이벤트가 자주 발생하는 UI 에서 반복을 줄이는 데 유용합니다."

L["Max lines read per tooltip"] = "툴팁당 최대 읽기 줄 수"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "툴팁마다 읽는 텍스트 줄 수의 상한을 둡니다. 줄이 많은 툴팁(복잡한 아이템 등)은 더 짧은 읽기를 위해 잘릴 수 있습니다."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "대화 창이 열릴 때 NPC 인사말과 대화 옵션을 읽습니다. 스피커 아이콘이나 R 키로 다시 읽을 수 있습니다."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "공격대 경보 및 우두머리 감정표현 읽기"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "화면 상단 중앙에 표시되는 큰 경고문(공격대 경보, 우두머리 감정표현, 이벤트 알림)을 읽습니다."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "마우스를 올린 NPC 대화 선택지 읽기"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "마우스를 올렸을 때 대화 창의 각 선택지를 읽습니다. DMHC 같은 스킨이 그린 선택지도 포함합니다."
