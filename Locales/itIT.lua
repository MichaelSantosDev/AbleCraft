if GetLocale() ~= "itIT" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS: attivato."
L["UiTTS: disabled."] = "UiTTS: disattivato."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS: Apri Impostazioni -> AddOn -> UiTTS."
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS caricato. Usa /uitts config per aprire le opzioni."

L["00:%02d:%02d time remaining"] = "00:%02d:%02d tempo rimanente"
L["%d of %d collected."] = "%d di %d raccolti."
L["Read quest again (R)"] = "Rileggi la missione (R)"
L["Read dialog again (R)"] = "Rileggi il dialogo (R)"
L["Equipped:"] = "Equipaggiato:"

L["Gained %d XP."] = "Hai ottenuto %d PE."
L["Level up! Now level %d."] = "Sei salito di livello! Ora livello %d."

L["Experience / leveling"] = "Esperienza / salite di livello"
L["Read XP gains"] = "Leggi i guadagni di PE"
L["Reads how much experience the player gains, summarised in short batches."] =
    "Legge quanta esperienza ottieni, riassunta in brevi lotti."
L["Read level-ups"] = "Leggi le salite di livello"
L["Announces the new level when the player levels up."] =
    "Annuncia il nuovo livello quando il giocatore sale di livello."

L["Choose what UiTTS reads aloud (WoW TTS)."] = "Scegli ciò che UiTTS deve leggere ad alta voce (TTS di WoW)."

L["Reading categories"] = "Categorie di lettura"
L["Interface / UI buttons"] = "Interfaccia / pulsanti UI"
L["Stability / performance"] = "Stabilità / prestazioni"

L["Enable UiTTS"] = "Attiva UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "Attiva/disattiva completamente l'addon. Quando disattivato, nessun testo viene letto."

L["Interrupt speech when tooltip changes"] = "Interrompi la voce al cambio di tooltip"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "Ferma la lettura corrente e inizia subito il nuovo tooltip, senza attendere la fine del precedente."

L["Do not repeat identical text"] = "Non ripetere testo identico"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "Se il testo finale corrisponde all'ultimo letto per lo stesso tooltip, la ripetizione viene soppressa."

L["Use Alternate voice"] = "Usa voce alternativa"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "Usa la voce TTS alternativa invece di quella standard (richiede una voce alternativa configurata nelle opzioni vocali di WoW)."

L["Read tooltips (master)"] = "Leggi tooltip (generale)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "Interruttore principale per la lettura dei tooltip. Disattivandolo si sopprimono tutti i tooltip indipendentemente dalle opzioni individuali."

L["GameTooltip (items / general UI)"] = "GameTooltip (oggetti / UI generale)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "Legge i tooltip standard del gioco passando il mouse su oggetti, abilità ed elementi generali dell'interfaccia."

L["Minimap objects (icons/buttons)"] = "Oggetti della minimappa (icone/pulsanti)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "Legge i tooltip delle icone e dei pulsanti della minimappa. Utile quando GameTooltip è disattivato ma vuoi sentire le icone della mappa."

L["Spellbook"] = "Libro degli incantesimi"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "Legge i tooltip passando il mouse sulle abilità nel libro degli incantesimi."

L["Talent tree"] = "Albero dei talenti"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "Legge i tooltip passando il mouse sui talenti nell'albero dei talenti del personaggio."

L["Profession specializations"] = "Specializzazioni di Professione"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "Legge i tooltip di specializzazione nella schermata delle Professioni, inclusi i nodi di specializzazione e sblocco."

L["Trading Post / Perks"] = "Posto di Scambio / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "Legge i tooltip del Posto di Scambio e del programma Perks passando il mouse su ricompense e oggetti."

L["Quest rewards (incl. DialogueUI)"] = "Ricompense di missione (incl. DialogueUI)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "Legge i tooltip di ricompensa missione nelle UI native del gioco e in addon come DialogueUI."

L["Quest window (QuestFrame)"] = "Finestra di missione (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "Legge ad alta voce descrizione e obiettivi della finestra di missione predefinita all'apertura. Usa l'icona dell'altoparlante o premi R per riavviare la lettura."

L["NPC dialog window (GossipFrame)"] = "Finestra di dialogo PNG (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "Legge il testo di saluto del PNG e le opzioni di dialogo all'apertura della finestra di gossip."

L["Guild Registrar window"] = "Finestra del Cancelliere di gilda"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "Legge ad alta voce il saluto e l'elenco dei servizi del dialogo del Maestro di gilda / Petizionario."

L["DialogueUI option buttons"] = "Pulsanti di opzione di DialogueUI"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "Legge l'etichetta dei pulsanti gossip / accetta / esci di DialogueUI al passaggio del mouse."

L["Item links in chat"] = "Collegamenti agli oggetti nella chat"
L["Reads tooltips when clicking item links in chat."] =
    "Legge i tooltip cliccando sui collegamenti degli oggetti nella chat."

L["Shopping comparison (ShoppingTooltip)"] = "Confronto d'acquisto (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "Legge i tooltip di confronto mostrati tenendo Shift su un oggetto, permettendo di sentire le differenze di statistiche."

L["Capture dynamic tooltips (scan)"] = "Cattura tooltip dinamici (scansione)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "Cerca e registra tooltip creati da addon fuori dal flusso standard di WoW. Necessario per alcuni addon come DialogueUI."

L["Game menu (ESC)"] = "Menu di gioco (ESC)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "Legge l'etichetta del pulsante al passaggio del mouse sul menu aperto premendo ESC."

L["Settings buttons and controls"] = "Pulsanti e controlli delle Impostazioni"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "Legge l'etichetta visibile dei controlli nel pannello Impostazioni al passaggio del mouse."

L["Settings option tooltips"] = "Tooltip delle opzioni di Impostazioni"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "Legge il titolo e la descrizione del tooltip mostrato al passaggio del mouse su un'opzione delle Impostazioni."

L["Read center notifications / Event Toasts"] = "Leggi notifiche centrali / Event Toast"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "Legge le notifiche al centro dello schermo, come obiettivi completati e inizi di evento."

L["Read center screen messages (UIErrors)"] = "Leggi messaggi al centro dello schermo (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "Legge messaggi brevi mostrati al centro dello schermo, come errori, avvisi e azioni non disponibili."

L["Read choice options (PlayerChoice)"] = "Leggi opzioni di scelta (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "Legge il titolo e la descrizione dell'opzione/carta al passaggio del mouse nella finestra di scelta del giocatore."

L["Read objective tracker events"] = "Leggi eventi del tracker obiettivi"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "Legge gli eventi a tempo del tracker obiettivi, incluso il tempo rimanente e il progresso raccolto."

L["Read information panels"] = "Leggi pannelli informativi"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "Legge pannelli descrittivi nelle finestre del gioco, come la descrizione delle Razze Alleate e altre schermate di dettaglio. Il testo viene letto passando il mouse sull'area di contenuto."

L["Read shop UI"] = "Leggi interfaccia del negozio"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "Legge testi e pulsanti visibili del negozio del gioco passando il mouse su prodotti e pulsanti d'azione, inclusi nome, descrizione, prezzo e pulsanti come 'Dettagli' e 'Acquista'."

L["Read Group Finder banners"] = "Leggi banner Cerca Gruppo"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "Legge il banner 'Nuova Stagione' / 'Nuovi Contenuti' che appare nella finestra Cerca Gruppo."

L["Debug log (UI Reader)"] = "Log di debug (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "Stampa nella chat informazioni di debug sulla lettura di pulsanti e tooltip dell'UI. Usalo solo per diagnosticare problemi."

L["Debounce (sec)"] = "Debounce (sec)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "Tempo di attesa dopo l'apparizione di un tooltip prima di iniziare a leggerlo. Aumentarlo riduce le letture accidentali durante movimenti rapidi del mouse."

L["Minimum global interval (sec)"] = "Intervallo minimo globale (sec)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "Tempo minimo tra due letture consecutive. Evita sovrapposizioni quando i tooltip cambiano rapidamente."

L["Scan interval (sec)"] = "Intervallo di scansione (sec)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "Quanto spesso l'addon cerca tooltip dinamici creati da altri addon. Valori più bassi rilevano più velocemente ma usano più CPU."

L["Per-owner time lock (sec) (optional)"] = "Blocco per tempo (sec) (opzionale)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "Dopo aver letto un tooltip, ignora nuovi tooltip dello stesso proprietario per questa durata. Usa 0 per disattivare. Utile per evitare ripetizioni in UI con eventi frequenti."

L["Max lines read per tooltip"] = "Righe massime lette per tooltip"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "Limita quante righe di testo vengono lette per tooltip. Tooltip lunghi (come oggetti complessi) possono essere troncati per letture più brevi."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "Legge il testo di saluto del PNG e le opzioni di dialogo all'apertura della finestra di gossip. Usa l'icona dell'altoparlante o premi R per riavviare la lettura."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "Leggi avvisi incursione ed emote dei boss"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "Legge i grandi avvisi mostrati in alto al centro dello schermo, come avvisi di incursione, emote dei boss e annunci degli eventi."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "Opzioni di dialogo del PNG al passaggio del mouse"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "Legge ogni opzione di dialogo della finestra di gossip quando il mouse ci passa sopra, incluse le opzioni disegnate da skin come DMHC."
