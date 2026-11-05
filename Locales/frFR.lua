if GetLocale() ~= "frFR" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS : activé."
L["UiTTS: disabled."] = "UiTTS : désactivé."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS : Ouvrez Paramètres -> AddOns -> UiTTS."
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS chargé. Utilisez /uitts config pour ouvrir les options."

L["00:%02d:%02d time remaining"] = "00:%02d:%02d temps restant"
L["%d of %d collected."] = "%d sur %d collectés."
L["Read quest again (R)"] = "Relire la quête (R)"
L["Read dialog again (R)"] = "Relire le dialogue (R)"
L["Equipped:"] = "Équipé :"

L["Gained %d XP."] = "Gain de %d XP."
L["Level up! Now level %d."] = "Niveau supérieur ! Niveau %d maintenant."

L["Experience / leveling"] = "Expérience / niveau"
L["Read XP gains"] = "Lire les gains d'XP"
L["Reads how much experience the player gains, summarised in short batches."] =
    "Lit l'expérience gagnée, regroupée en courts paquets."
L["Read level-ups"] = "Lire les passages de niveau"
L["Announces the new level when the player levels up."] =
    "Annonce le nouveau niveau quand le joueur monte d'un niveau."

L["Choose what UiTTS reads aloud (WoW TTS)."] = "Choisissez ce que UiTTS doit lire à voix haute (TTS de WoW)."

L["Reading categories"] = "Catégories de lecture"
L["Interface / UI buttons"] = "Interface / boutons d'IU"
L["Stability / performance"] = "Stabilité / performance"

L["Enable UiTTS"] = "Activer UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "Active/désactive complètement l'addon. Lorsqu'il est désactivé, aucun texte n'est lu."

L["Interrupt speech when tooltip changes"] = "Interrompre la voix au changement d'infobulle"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "Arrête la lecture en cours et commence immédiatement la nouvelle infobulle, sans attendre la fin de la précédente."

L["Do not repeat identical text"] = "Ne pas répéter le texte identique"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "Si le texte final correspond au dernier lu pour la même infobulle, supprime la répétition."

L["Use Alternate voice"] = "Utiliser la voix alternative"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "Utilise la voix TTS alternative au lieu de la voix standard (nécessite une voix alternative configurée dans les options vocales de WoW)."

L["Read tooltips (master)"] = "Lire les infobulles (général)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "Bascule principale pour la lecture des infobulles. La désactiver supprime toutes les infobulles, indépendamment des options individuelles ci-dessous."

L["GameTooltip (items / general UI)"] = "GameTooltip (objets / IU générale)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "Lit les infobulles standards du jeu lors du survol d'objets, sorts et éléments d'IU généraux."

L["Minimap objects (icons/buttons)"] = "Objets de la minicarte (icônes/boutons)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "Lit les infobulles des icônes et boutons de la minicarte. Utile lorsque GameTooltip est désactivé mais que vous voulez entendre les icônes de la carte."

L["Spellbook"] = "Grimoire"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "Lit les infobulles lors du survol de sorts dans le grimoire."

L["Talent tree"] = "Arbre de talents"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "Lit les infobulles lors du survol des talents dans l'arbre de talents du personnage."

L["Profession specializations"] = "Spécialisations de métier"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "Lit les infobulles de spécialisation dans l'écran Métiers, incluant les nœuds de spécialisation et de déblocage."

L["Trading Post / Perks"] = "Comptoir commercial / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "Lit les infobulles du Comptoir commercial et du programme Perks lors du survol de récompenses et d'objets."

L["Quest rewards (incl. DialogueUI)"] = "Récompenses de quête (incl. DialogueUI)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "Lit les infobulles de récompenses de quête dans les IU natives du jeu et les addons tels que DialogueUI."

L["Quest window (QuestFrame)"] = "Fenêtre de quête (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "Lit à voix haute la description et les objectifs de la fenêtre de quête par défaut lors de l'ouverture. Utilisez l'icône haut-parleur ou appuyez sur R pour relancer la lecture."

L["NPC dialog window (GossipFrame)"] = "Fenêtre de dialogue PNJ (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "Lit le texte d'accueil du PNJ et les options de dialogue à l'ouverture de la fenêtre de gossip."

L["Guild Registrar window"] = "Fenêtre du Greffier de guilde"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "Lit à voix haute le message d'accueil et la liste des services du dialogue du Maître de guilde / Pétitionnaire."

L["DialogueUI option buttons"] = "Boutons d'option de DialogueUI"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "Lit le libellé des boutons de gossip / accepter / sortir de DialogueUI lors du survol."

L["Item links in chat"] = "Liens d'objet dans le chat"
L["Reads tooltips when clicking item links in chat."] =
    "Lit les infobulles lors du clic sur les liens d'objet dans le chat."

L["Shopping comparison (ShoppingTooltip)"] = "Comparaison d'achat (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "Lit les infobulles de comparaison affichées en maintenant Maj au-dessus d'un objet, permettant d'entendre les différences de statistiques."

L["Capture dynamic tooltips (scan)"] = "Capturer les infobulles dynamiques (scan)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "Recherche et enregistre les infobulles créées par des addons en dehors du flux standard de WoW. Nécessaire pour certains addons comme DialogueUI."

L["Game menu (ESC)"] = "Menu du jeu (Échap)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "Lit le libellé du bouton lors du survol du menu ouvert avec Échap."

L["Settings buttons and controls"] = "Boutons et contrôles des Paramètres"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "Lit le libellé visible des contrôles du panneau Paramètres lors du survol."

L["Settings option tooltips"] = "Infobulles des options de Paramètres"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "Lit le titre et la description de l'infobulle affichée lors du survol d'une option des Paramètres."

L["Read center notifications / Event Toasts"] = "Lire les notifications centrales / Event Toasts"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "Lit les notifications au centre de l'écran telles que les objectifs terminés et les débuts d'événement."

L["Read center screen messages (UIErrors)"] = "Lire les messages au centre de l'écran (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "Lit les messages courts affichés au centre de l'écran, tels que les erreurs, avertissements et actions indisponibles."

L["Read choice options (PlayerChoice)"] = "Lire les options de choix (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "Lit le titre et la description de l'option/carte lors du survol dans la fenêtre de choix du joueur."

L["Read objective tracker events"] = "Lire les événements du suivi d'objectifs"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "Lit les événements minutés du suivi d'objectifs, incluant le temps restant et la progression."

L["Read information panels"] = "Lire les panneaux d'information"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "Lit les panneaux descriptifs dans les fenêtres du jeu, comme la description des Races alliées et autres écrans de détail. Le texte est lu lors du survol de la zone de contenu."

L["Read shop UI"] = "Lire l'interface boutique"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "Lit les textes et boutons visibles de la boutique du jeu lors du survol de produits et boutons d'action, incluant nom, description, prix et boutons comme « Détails » et « Acheter »."

L["Read Group Finder banners"] = "Lire les bannières du Recherche de groupe"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "Lit la bannière « Nouvelle saison » / « Nouveau contenu » qui apparaît dans la fenêtre Recherche de groupe."

L["Debug log (UI Reader)"] = "Journal de débogage (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "Affiche dans le chat des informations de débogage sur la lecture de boutons et d'infobulles d'IU. À utiliser uniquement pour diagnostiquer des problèmes."

L["Debounce (sec)"] = "Anti-rebond (sec)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "Temps d'attente après l'apparition d'une infobulle avant de commencer à la lire. Augmenter réduit les lectures accidentelles lors de mouvements rapides de la souris."

L["Minimum global interval (sec)"] = "Intervalle minimum global (sec)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "Temps minimum entre deux lectures consécutives. Empêche les chevauchements lorsque les infobulles changent rapidement."

L["Scan interval (sec)"] = "Intervalle de scan (sec)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "Fréquence à laquelle l'addon recherche les infobulles dynamiques créées par d'autres addons. Valeurs plus basses : détection plus rapide mais plus de CPU."

L["Per-owner time lock (sec) (optional)"] = "Verrou temporel par propriétaire (sec) (optionnel)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "Après la lecture d'une infobulle, ignore les nouvelles infobulles du même propriétaire pendant cette durée. 0 pour désactiver. Utile pour éviter les répétitions dans les IU à événements fréquents."

L["Max lines read per tooltip"] = "Lignes maximum lues par infobulle"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "Limite le nombre de lignes lues par infobulle. Les infobulles longues (objets complexes) peuvent être tronquées pour des lectures plus courtes."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "Lit le texte d'accueil du PNJ et les options de dialogue à l'ouverture de la fenêtre de gossip. Utilisez l'icône haut-parleur ou appuyez sur R pour relancer la lecture."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "Lire les avertissements de raid et les emotes de boss"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "Lit les grands avertissements affichés en haut au centre de l'écran, comme les avertissements de raid, les emotes de boss et les annonces d'événements."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "Options de dialogue du PNJ au survol"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "Lit chaque option de dialogue de la fenêtre de gossip lorsque la souris la survole, y compris les options dessinées par des skins comme DMHC."
