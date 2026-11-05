if GetLocale() ~= "esES" then return end
local L = UiTTS_L

L["UiTTS: enabled."] = "UiTTS: activado."
L["UiTTS: disabled."] = "UiTTS: desactivado."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS: Abre Ajustes -> AddOns -> UiTTS."
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS cargado. Usa /uitts config para abrir las opciones."

L["00:%02d:%02d time remaining"] = "00:%02d:%02d tiempo restante"
L["%d of %d collected."] = "%d de %d recogidos."
L["Read quest again (R)"] = "Leer la misión de nuevo (R)"
L["Read dialog again (R)"] = "Leer el diálogo de nuevo (R)"
L["Equipped:"] = "Equipado:"

L["Gained %d XP."] = "Ganaste %d PX."
L["Level up! Now level %d."] = "¡Subida de nivel! Ahora nivel %d."

L["Experience / leveling"] = "Experiencia / subida de nivel"
L["Read XP gains"] = "Leer ganancias de XP"
L["Reads how much experience the player gains, summarised in short batches."] =
    "Lee cuánta experiencia ganas, resumida en pequeños lotes."
L["Read level-ups"] = "Leer subidas de nivel"
L["Announces the new level when the player levels up."] =
    "Anuncia el nuevo nivel cuando el jugador sube de nivel."

L["Choose what UiTTS reads aloud (WoW TTS)."] = "Elige qué debe leer UiTTS en voz alta (TTS de WoW)."

L["Reading categories"] = "Categorías de lectura"
L["Interface / UI buttons"] = "Interfaz / botones de IU"
L["Stability / performance"] = "Estabilidad / rendimiento"

L["Enable UiTTS"] = "Activar UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "Activa o desactiva el addon por completo. Cuando está desactivado, no se lee ningún texto."

L["Interrupt speech when tooltip changes"] = "Interrumpir la lectura al cambiar de tooltip"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "Detiene la lectura actual y empieza a leer el nuevo tooltip de inmediato, sin esperar a que termine el anterior."

L["Do not repeat identical text"] = "No repetir texto idéntico"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "Si el texto final coincide con el último leído para el mismo tooltip, se omite la repetición."

L["Use Alternate voice"] = "Usar voz alternativa"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "Usa la voz alternativa de TTS en lugar de la estándar (requiere una voz alternativa configurada en las opciones de voz de WoW)."

L["Read tooltips (master)"] = "Leer tooltips (general)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "Interruptor maestro para la lectura de tooltips. Al desactivarlo se suprimen todos los tooltips independientemente de las opciones individuales."

L["GameTooltip (items / general UI)"] = "GameTooltip (objetos / IU general)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "Lee los tooltips estándar del juego al pasar el ratón sobre objetos, habilidades y elementos generales de la IU."

L["Minimap objects (icons/buttons)"] = "Objetos del minimapa (iconos/botones)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "Lee los tooltips de iconos y botones del minimapa. Útil cuando GameTooltip está desactivado pero quieres oír los iconos del mapa."

L["Spellbook"] = "Libro de hechizos"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "Lee los tooltips al pasar el ratón sobre habilidades en el libro de hechizos."

L["Talent tree"] = "Árbol de talentos"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "Lee los tooltips al pasar el ratón sobre talentos en el árbol de talentos del personaje."

L["Profession specializations"] = "Especializaciones de Profesión"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "Lee los tooltips de especialización en la pantalla de Profesiones, incluidos los nodos de especialización y desbloqueo."

L["Trading Post / Perks"] = "Puesto Comercial / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "Lee los tooltips del Puesto Comercial y del programa Perks al pasar el ratón sobre recompensas y objetos."

L["Quest rewards (incl. DialogueUI)"] = "Recompensas de misión (incl. DialogueUI)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "Lee tooltips de recompensa de misión en las IU nativas del juego y en addons como DialogueUI."

L["Quest window (QuestFrame)"] = "Ventana de misión (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "Lee en voz alta la descripción y objetivos de la ventana de misión predeterminada al abrirla. Usa el icono de altavoz o pulsa R para reiniciar la lectura."

L["NPC dialog window (GossipFrame)"] = "Ventana de diálogo de PNJ (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "Lee el texto de saludo del PNJ y las opciones de diálogo al abrir la ventana de gossip."

L["Guild Registrar window"] = "Ventana del Registrador de Hermandad"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "Lee en voz alta el saludo y la lista de servicios del diálogo del Maestro de Hermandad / Peticionario."

L["DialogueUI option buttons"] = "Botones de opción de DialogueUI"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "Lee la etiqueta de los botones de gossip / aceptar / salir de DialogueUI al pasar el ratón."

L["Item links in chat"] = "Enlaces de objeto en el chat"
L["Reads tooltips when clicking item links in chat."] =
    "Lee los tooltips al hacer clic en enlaces de objeto en el chat."

L["Shopping comparison (ShoppingTooltip)"] = "Comparación de compra (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "Lee los tooltips de comparación que aparecen al mantener Mayús sobre un objeto, permitiendo oír las diferencias de atributos."

L["Capture dynamic tooltips (scan)"] = "Capturar tooltips dinámicos (escaneo)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "Busca y registra tooltips creados por addons fuera del flujo estándar de WoW. Necesario para algunos addons como DialogueUI."

L["Game menu (ESC)"] = "Menú de juego (ESC)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "Lee la etiqueta del botón al pasar el ratón en el menú que abre al pulsar ESC."

L["Settings buttons and controls"] = "Botones y controles de Ajustes"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "Lee la etiqueta visible de los controles en el panel de Ajustes al pasar el ratón."

L["Settings option tooltips"] = "Tooltips de opciones de Ajustes"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "Lee el título y la descripción del tooltip mostrado al pasar el ratón sobre una opción de Ajustes."

L["Read center notifications / Event Toasts"] = "Leer avisos centrales / Event Toasts"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "Lee los avisos en el centro de la pantalla, como objetivos completados e inicios de eventos."

L["Read center screen messages (UIErrors)"] = "Leer mensajes centrales de pantalla (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "Lee mensajes breves mostrados en el centro de la pantalla, como errores, avisos y acciones no disponibles."

L["Read choice options (PlayerChoice)"] = "Leer opciones de elección (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "Lee el título y descripción de la opción/tarjeta al pasar el ratón en la ventana de elección del jugador."

L["Read objective tracker events"] = "Leer eventos del rastreador de objetivos"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "Lee eventos temporizados del rastreador de objetivos, incluido el tiempo restante y el progreso recogido."

L["Read information panels"] = "Leer paneles de información"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "Lee paneles descriptivos en ventanas del juego, como la descripción de Razas Aliadas y otras pantallas de detalles. El texto se lee al pasar el ratón sobre el área de contenido."

L["Read shop UI"] = "Leer interfaz de la tienda"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "Lee los textos y botones visibles de la tienda del juego al pasar el ratón sobre productos y botones de acción, incluidos nombre, descripción, precio y botones como 'Detalles' y 'Comprar'."

L["Read Group Finder banners"] = "Leer banners del Buscador de Grupos"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "Lee el cartel 'Nueva Temporada' / 'Nuevo Contenido' que aparece en la ventana del Buscador de Grupos."

L["Debug log (UI Reader)"] = "Registro de depuración (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "Imprime en el chat información de depuración sobre la lectura de botones y tooltips de IU. Úsalo solo para diagnosticar problemas."

L["Debounce (sec)"] = "Antirrebote (seg)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "Tiempo de espera tras aparecer un tooltip antes de empezar a leerlo. Valores más altos reducen lecturas accidentales al mover el ratón rápidamente."

L["Minimum global interval (sec)"] = "Intervalo mínimo global (seg)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "Tiempo mínimo entre dos lecturas consecutivas. Evita que los textos se solapen cuando los tooltips cambian rápido."

L["Scan interval (sec)"] = "Intervalo de escaneo (seg)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "Con qué frecuencia el addon busca tooltips dinámicos creados por otros addons. Valores menores detectan más rápido pero usan más CPU."

L["Per-owner time lock (sec) (optional)"] = "Bloqueo por tiempo (seg) (opcional)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "Tras leer un tooltip, ignora los nuevos tooltips del mismo propietario durante este tiempo. Usa 0 para desactivarlo. Útil para evitar repeticiones en IU con eventos frecuentes."

L["Max lines read per tooltip"] = "Máx. líneas leídas por tooltip"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "Limita cuántas líneas se leen por tooltip. Los tooltips largos (como objetos complejos) pueden truncarse para lecturas más cortas."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "Lee el texto de saludo del PNJ y las opciones de diálogo al abrir la ventana de gossip. Usa el icono de altavoz o pulsa R para reiniciar la lectura."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "Leer avisos de banda y emotes de jefe"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "Lee los avisos grandes mostrados en la parte superior central de la pantalla, como avisos de banda, emotes de jefes y anuncios de eventos."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "Opciones de diálogo del PNJ al pasar el ratón"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "Lee cada opción de diálogo de la ventana de gossip al pasar el ratón por encima, incluidas las opciones dibujadas por skins como DMHC."
