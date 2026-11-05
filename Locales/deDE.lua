if GetLocale() ~= "deDE" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS: aktiviert."
L["UiTTS: disabled."] = "UiTTS: deaktiviert."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS: Öffne Einstellungen -> AddOns -> UiTTS."
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS geladen. Verwende /uitts config, um die Optionen zu öffnen."

L["00:%02d:%02d time remaining"] = "00:%02d:%02d verbleibende Zeit"
L["%d of %d collected."] = "%d von %d gesammelt."
L["Read quest again (R)"] = "Quest erneut vorlesen (R)"
L["Read dialog again (R)"] = "Dialog erneut vorlesen (R)"
L["Equipped:"] = "Angelegt:"

L["Gained %d XP."] = "%d EP erhalten."
L["Level up! Now level %d."] = "Aufstieg! Jetzt Stufe %d."

L["Experience / leveling"] = "Erfahrung / Aufstieg"
L["Read XP gains"] = "Erfahrungspunkte vorlesen"
L["Reads how much experience the player gains, summarised in short batches."] =
    "Liest vor, wie viel Erfahrung der Spieler erhält, in kurzen Sammelmeldungen."
L["Read level-ups"] = "Stufenaufstiege vorlesen"
L["Announces the new level when the player levels up."] =
    "Kündigt die neue Stufe an, wenn der Spieler aufsteigt."

L["Choose what UiTTS reads aloud (WoW TTS)."] = "Wähle, was UiTTS laut vorlesen soll (WoW TTS)."

L["Reading categories"] = "Lese-Kategorien"
L["Interface / UI buttons"] = "Interface / UI-Schaltflächen"
L["Stability / performance"] = "Stabilität / Leistung"

L["Enable UiTTS"] = "UiTTS aktivieren"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "Schaltet das AddOn komplett ein/aus. Wenn deaktiviert, wird kein Text vorgelesen."

L["Interrupt speech when tooltip changes"] = "Sprache unterbrechen bei neuem Tooltip"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "Stoppt die aktuelle Sprachausgabe und liest den neuen Tooltip sofort vor, ohne auf das Ende des vorherigen zu warten."

L["Do not repeat identical text"] = "Identischen Text nicht wiederholen"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "Wenn der Text dem zuletzt gesprochenen Text desselben Tooltips entspricht, wird die Wiederholung unterdrückt."

L["Use Alternate voice"] = "Alternative Stimme verwenden"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "Verwendet die alternative TTS-Stimme statt der Standardstimme (benötigt eine in den WoW-Sprachoptionen konfigurierte alternative Stimme)."

L["Read tooltips (master)"] = "Tooltips vorlesen (Hauptschalter)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "Hauptschalter für das Vorlesen von Tooltips. Wenn deaktiviert, werden alle Tooltips unterdrückt, unabhängig von den einzelnen Optionen unten."

L["GameTooltip (items / general UI)"] = "GameTooltip (Gegenstände / allgemeine UI)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "Liest Standard-Spiel-Tooltips beim Hovern über Gegenstände, Fähigkeiten und allgemeine UI-Elemente vor."

L["Minimap objects (icons/buttons)"] = "Minikarten-Objekte (Symbole/Schaltflächen)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "Liest Tooltips von Minikarten-Symbolen und -Schaltflächen vor. Nützlich, wenn der allgemeine GameTooltip aus ist, aber Minikarten-Symbole gehört werden sollen."

L["Spellbook"] = "Zauberbuch"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "Liest Tooltips beim Hovern über Fähigkeiten im Zauberbuch vor."

L["Talent tree"] = "Talentbaum"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "Liest Tooltips beim Hovern über Talente im Talentbaum des Charakters vor."

L["Profession specializations"] = "Berufsspezialisierungen"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "Liest Spezialisierungs-Tooltips im Berufsfenster vor, einschließlich Spezialisierungs- und Freischaltknoten."

L["Trading Post / Perks"] = "Handelsposten / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "Liest Tooltips des Handelspostens und des Perks-Programms beim Hovern über Belohnungen und Gegenstände vor."

L["Quest rewards (incl. DialogueUI)"] = "Quest-Belohnungen (inkl. DialogueUI)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "Liest Quest-Belohnungs-Tooltips in nativen Spiel-UIs und AddOns wie DialogueUI vor."

L["Quest window (QuestFrame)"] = "Questfenster (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "Liest beim Öffnen Beschreibung und Ziele des Standard-Questfensters vor. Verwende das Lautsprechersymbol oder drücke R, um die Wiedergabe neu zu starten."

L["NPC dialog window (GossipFrame)"] = "NPC-Dialogfenster (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "Liest beim Öffnen des Gossip-Fensters den Begrüßungstext und die Dialogoptionen des NPCs vor."

L["Guild Registrar window"] = "Gildenregistrar-Fenster"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "Liest die Begrüßung und Dienstleistungsliste des Gildenmeister-/Bittsteller-Dialogs vor."

L["DialogueUI option buttons"] = "DialogueUI-Optionsschaltflächen"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "Liest beim Hovern die Beschriftung der DialogueUI-Schaltflächen für Gossip, Annehmen und Verlassen vor."

L["Item links in chat"] = "Gegenstandslinks im Chat"
L["Reads tooltips when clicking item links in chat."] =
    "Liest Tooltips beim Klicken auf Gegenstandslinks im Chat vor."

L["Shopping comparison (ShoppingTooltip)"] = "Einkaufsvergleich (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "Liest Vergleichs-Tooltips vor, die angezeigt werden, wenn Shift über einem Gegenstand gehalten wird, sodass Attributunterschiede hörbar werden."

L["Capture dynamic tooltips (scan)"] = "Dynamische Tooltips erfassen (Scan)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "Sucht und registriert Tooltips, die von AddOns außerhalb des WoW-Standardflusses erstellt werden. Wird für einige AddOns wie DialogueUI benötigt."

L["Game menu (ESC)"] = "Spielmenü (ESC)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "Liest beim Hovern die Schaltflächenbeschriftung im Menü vor, das durch Drücken von ESC geöffnet wird."

L["Settings buttons and controls"] = "Einstellungs-Schaltflächen und -Steuerelemente"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "Liest beim Hovern die sichtbare Beschriftung der Steuerelemente im Einstellungsfenster vor."

L["Settings option tooltips"] = "Tooltips von Einstellungsoptionen"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "Liest Titel und Beschreibung des Tooltips vor, der beim Hovern einer Einstellungsoption angezeigt wird."

L["Read center notifications / Event Toasts"] = "Bildschirm-Benachrichtigungen / Event Toasts vorlesen"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "Liest Benachrichtigungen in der Bildschirmmitte vor, wie z. B. abgeschlossene Ziele und Ereignisbeginne."

L["Read center screen messages (UIErrors)"] = "Bildschirmmittelnachrichten vorlesen (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "Liest kurze Nachrichten in der Bildschirmmitte vor, wie Fehler, Warnungen und nicht verfügbare Aktionen."

L["Read choice options (PlayerChoice)"] = "Auswahl-Optionen vorlesen (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "Liest beim Hovern Titel und Beschreibung einer Option/Karte im Spielerauswahlfenster vor."

L["Read objective tracker events"] = "Zielverfolgungs-Ereignisse vorlesen"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "Liest zeitgesteuerte Ereignisse der Zielverfolgung vor, einschließlich verbleibender Zeit und Fortschritt."

L["Read information panels"] = "Informationsfenster vorlesen"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "Liest beschreibende Tafeln in Spielfenstern vor, wie die Beschreibung verbündeter Völker und andere Detailansichten. Der Text wird beim Hovern über den Inhaltsbereich vorgelesen."

L["Read shop UI"] = "Shop-Oberfläche vorlesen"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "Liest sichtbare Texte und Schaltflächen im Ingame-Shop beim Hovern von Produkten und Aktionsschaltflächen vor, inklusive Name, Beschreibung, Preis und Schaltflächen wie 'Details' und 'Kaufen'."

L["Read Group Finder banners"] = "Gruppensuche-Banner vorlesen"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "Liest das Banner 'Neue Saison' / 'Neuer Inhalt' im Fenster der Gruppensuche vor, wenn es erscheint."

L["Debug log (UI Reader)"] = "Debug-Log (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "Schreibt Debug-Informationen zum Vorlesen von Schaltflächen und UI-Tooltips in den Chat. Nur zur Fehlerdiagnose verwenden."

L["Debounce (sec)"] = "Debounce (Sek.)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "Wartezeit, bevor das Vorlesen eines Tooltips beginnt. Höhere Werte reduzieren versehentliches Vorlesen bei schnellen Mausbewegungen."

L["Minimum global interval (sec)"] = "Globales Mindestintervall (Sek.)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "Mindestzeit zwischen zwei aufeinanderfolgenden Lesevorgängen. Verhindert überlappende Sprachausgabe bei schnell wechselnden Tooltips."

L["Scan interval (sec)"] = "Scan-Intervall (Sek.)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "Wie oft das AddOn nach dynamischen Tooltips anderer AddOns sucht. Niedrigere Werte erkennen sie schneller, verbrauchen aber mehr CPU."

L["Per-owner time lock (sec) (optional)"] = "Besitzer-Zeitsperre (Sek.) (optional)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "Ignoriert nach dem Vorlesen eines Tooltips für diese Dauer neue Tooltips desselben Besitzers. 0 deaktiviert. Vermeidet Wiederholungen in UIs mit häufigen Ereignissen."

L["Max lines read per tooltip"] = "Maximale Zeilen pro Tooltip"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "Begrenzt die Anzahl gelesener Textzeilen pro Tooltip. Tooltips mit vielen Zeilen (z. B. komplexe Gegenstände) können für kürzere Wiedergaben gekürzt werden."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "Liest beim Öffnen des Gossip-Fensters den Begrüßungstext und die Dialogoptionen des NPCs vor. Verwende das Lautsprechersymbol oder drücke R, um die Wiedergabe neu zu starten."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "Schlachtzugswarnungen und Boss-Emotes vorlesen"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "Liest die großen Warnungen oben in der Bildschirmmitte vor, etwa Schlachtzugswarnungen, Boss-Emotes und Ereignisankündigungen."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "Dialogoptionen des NPCs beim Überfahren"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "Liest jede Dialogoption des Gossip-Fensters vor, wenn die Maus darüberfährt, auch Optionen, die von Skins wie DMHC gezeichnet werden."
