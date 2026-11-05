if GetLocale() ~= "ptBR" then return end
local L = UiTTS_L

-- ===== Slash command and load messages =====
L["UiTTS: enabled."] = "UiTTS: ligado."
L["UiTTS: disabled."] = "UiTTS: desligado."
L["UiTTS: Open Settings -> AddOns -> UiTTS."] = "UiTTS: Abra Configurações -> AddOns -> UiTTS."
L["UiTTS: /uitts on | off | toggle | stop | config"] = "UiTTS: /uitts on | off | toggle | stop | config"
L["UiTTS loaded. Use /uitts config to open options."] = "UiTTS carregado. Use /uitts config para abrir as opções."

L["UiTTS test. One, two, three."] = "Teste do UiTTS. Um, dois, três."
L["Press Ctrl+A then Ctrl+C to copy."] = "Pressione Ctrl+A e depois Ctrl+C para copiar."
L["Close"] = "Fechar"

-- ===== UIReader runtime strings =====
L["00:%02d:%02d time remaining"] = "00:%02d:%02d Tempo restante"
L["%d of %d collected."] = "%d de %d coletados."
L["Read quest again (R)"] = "Ler a missão de novo (R)"
L["Read dialog again (R)"] = "Ler o diálogo de novo (R)"
L["Equipped:"] = "Equipado:"

-- ===== XpTTS runtime strings =====
L["Gained %d XP."] = "Ganhou %d de XP."
L["Level up! Now level %d."] = "Subiu de nível! Agora nível %d."

-- ===== XpTTS options =====
L["Experience / leveling"] = "Experiência / nivelamento"
L["Read XP gains"] = "Ler ganhos de XP"
L["Reads how much experience the player gains, summarised in short batches."] =
    "Lê quanta experiência o jogador ganhou, resumida em pequenos blocos."
L["Read level-ups"] = "Ler aumentos de nível"
L["Announces the new level when the player levels up."] =
    "Anuncia o novo nível quando o jogador sobe de nível."

-- ===== Options panel =====
L["Choose what UiTTS reads aloud (WoW TTS)."] = "Escolha o que o UiTTS deve ler em voz alta (TTS do WoW)."

L["Reading categories"] = "Categorias de leitura"
L["Interface / UI buttons"] = "Interface / botões de UI"
L["Stability / performance"] = "Estabilidade / desempenho"

-- Checkboxes (label / tooltip)
L["Enable UiTTS"] = "Ativar UiTTS"
L["Turns the addon on/off entirely. When disabled, no text is read."] =
    "Liga/desliga o addon completamente. Quando desativado, nenhum texto é lido."

L["Interrupt speech when tooltip changes"] = "Interromper fala ao mudar tooltip"
L["Stops the current speech and starts reading the new tooltip immediately, without waiting for the previous one to finish."] =
    "Para a fala atual e começa a ler o novo tooltip imediatamente, sem esperar o texto anterior terminar."

L["Do not repeat identical text"] = "Não repetir texto idêntico"
L["If the final text matches the last spoken text for the same tooltip, suppress the repeat."] =
    "Se o texto final for igual ao último lido para o mesmo tooltip, ignora a repetição."

L["Use Alternate voice"] = "Usar voz Alternate"
L["Uses the Alternate TTS voice instead of the Standard one (requires an Alternate voice configured in WoW's voice options)."] =
    "Usa a voz Alternate do TTS em vez da voz padrão (requer voz Alternate configurada nas opções de voz do WoW)."

L["Read tooltips (master)"] = "Ler tooltips (geral)"
L["Master toggle for tooltip reading. Disabling this suppresses all tooltips regardless of the individual options below."] =
    "Chave mestra para leitura de tooltips. Desativar esta opção suprime todos os tooltips, independente das opções individuais abaixo."

L["GameTooltip (items / general UI)"] = "GameTooltip (itens / UI geral)"
L["Reads standard game tooltips when hovering items, abilities, and general UI elements."] =
    "Lê os tooltips normais do jogo ao passar o mouse sobre itens, habilidades e elementos de UI gerais."

L["Minimap objects (icons/buttons)"] = "Objetos do minimapa (ícones/botões)"
L["Reads minimap icon and button tooltips. Useful when GameTooltip is off but you still want to hear minimap icons."] =
    "Lê tooltips de ícones e botões no minimapa. Útil quando o GameTooltip geral está desativado mas você quer ouvir os ícones do mapa."

L["Spellbook"] = "Spellbook"
L["Reads tooltips when hovering abilities in the spellbook."] =
    "Lê tooltips de habilidades ao passar o mouse no livro de magias."

L["Talent tree"] = "Árvore de talentos"
L["Reads tooltips when hovering talents in the character talent tree."] =
    "Lê tooltips ao passar o mouse sobre talentos na árvore de talentos do personagem."

L["Profession specializations"] = "Especializações de Profissão"
L["Reads specialization tooltips on the Professions screen, including specialization and unlock nodes."] =
    "Lê tooltips de especialização na tela de Profissões, incluindo nós de especialização e desbloqueio."

L["Trading Post / Perks"] = "Posto Comercial / Perks"
L["Reads Trading Post and Perks Program tooltips when hovering rewards and items."] =
    "Lê tooltips do Trading Post e do Perks Program ao passar o mouse sobre recompensas e itens."

L["Quest rewards (incl. DialogueUI)"] = "Recompensas de missão (inclui DialogueUI)"
L["Reads quest reward tooltips in native game UIs and addons such as DialogueUI."] =
    "Lê tooltips de recompensa de missão em UIs nativas do jogo ou em addons como o DialogueUI."

L["Quest window (QuestFrame)"] = "Janela de missão (QuestFrame)"
L["Reads the description and objectives of WoW's default quest window when opened. Use the speaker icon or press R to restart the read."] =
    "Lê em voz alta a descrição e objetivos da janela de missão padrão do WoW ao abri-la. Use o ícone de alto-falante ou pressione R para reiniciar a leitura."

L["NPC dialog window (GossipFrame)"] = "Janela de diálogo NPC (GossipFrame)"
L["Reads the NPC greeting text and dialog options when the gossip window opens."] =
    "Lê em voz alta o texto de saudação do NPC e as opções de diálogo quando a janela de gossip abre."

L["Guild Registrar window"] = "Janela do Registrador de Guilda"
L["Reads the greeting and service list of the Guild Master / Petitioner dialog."] =
    "Lê em voz alta a saudação e a lista de serviços do diálogo do Mestre de Guilda / Peticionário."

L["DialogueUI option buttons"] = "Botões de opção do DialogueUI"
L["Reads the label of DialogueUI gossip / accept / exit buttons when hovered."] =
    "Lê em voz alta o rótulo dos botões de gossip / aceitar / sair do DialogueUI ao passar o mouse sobre eles."

L["Item links in chat"] = "Links de item no chat"
L["Reads tooltips when clicking item links in chat."] =
    "Lê tooltips ao clicar em links de item no chat."

L["Shopping comparison (ShoppingTooltip)"] = "Comparação de compra (ShoppingTooltip)"
L["Reads comparison tooltips shown while holding Shift over items, so stat differences can be heard."] =
    "Lê tooltips de comparação exibidos ao segurar Shift sobre itens, permitindo ouvir as diferenças de atributos."

L["Capture dynamic tooltips (scan)"] = "Capturar tooltips dinâmicos (scan)"
L["Searches for and registers tooltips created by addons outside WoW's standard flow. Required for some addons such as DialogueUI."] =
    "Busca e registra tooltips criados por addons fora do fluxo padrão do WoW. Necessário para alguns addons como o DialogueUI."

L["Game menu (ESC)"] = "Menu de jogo (ESC)"
L["Reads the button label when hovering items in the menu opened by pressing ESC."] =
    "Lê em voz alta o rótulo do botão ao passar o mouse no menu que abre ao pressionar ESC."

L["Settings buttons and controls"] = "Botões e controles de Configurações"
L["Reads the visible label of controls in the Settings panel when hovered."] =
    "Lê o rótulo visível de controles no painel de Configurações (Settings) ao passar o mouse sobre eles."

L["Settings option tooltips"] = "Tooltips de opções de Configurações"
L["Reads the title and description of the tooltip shown when hovering a Settings option."] =
    "Lê o título e a descrição do tooltip exibido ao passar o mouse sobre uma opção no painel de Configurações."

L["Read center notifications / Event Toasts"] = "Ler avisos centrais / Event Toasts"
L["Reads center-screen notifications such as completed objectives and event starts."] =
    "Lê caixas de aviso/notificação no centro da tela, como objetivos concluídos e eventos iniciados."

L["Read center screen messages (UIErrors)"] = "Ler avisos centrais da tela (UIErrors)"
L["Reads short messages shown at the center of the screen, such as errors, warnings, and unavailable actions."] =
    "Lê mensagens curtas exibidas no centro da tela, como erros, avisos e ações indisponíveis."

L["Read choice options (PlayerChoice)"] = "Ler opções de escolha (PlayerChoice)"
L["Reads the title and description of an option/card when hovered in the player choice window."] =
    "Lê o título e a descrição da opção/cartão ao passar o mouse na janela de escolha do jogador."

L["Read objective tracker events"] = "Ler eventos do rastreador de objetivos"
L["Reads timed events from the objective tracker, including time remaining and progress collected."] =
    "Lê eventos temporários do rastreador de objetivos, incluindo tempo restante e progresso coletado."

L["Read information panels"] = "Ler painéis de informação"
L["Reads descriptive panels in game windows, such as the Allied Races description and other detail screens. Text is read when hovering the panel's content area."] =
    "Lê painéis com texto descritivo em janelas do jogo, como a descrição de raças aliadas e outras telas de informação detalhada. O texto é lido ao passar o mouse sobre a área de conteúdo do painel."

L["Read shop UI"] = "Ler interface da loja"
L["Reads visible texts and buttons on the in-game shop when hovering products and action buttons, including name, description, price and buttons such as 'Details' and 'Buy'."] =
    "Lê textos e botões visíveis da loja do jogo ao passar o mouse sobre produtos e botões de ação, incluindo nome do produto, descrição, preço e botões como 'Detalhes' e 'Comprar'."

L["Read Group Finder banners"] = "Ler banners do Localizador de Grupos"
L["Reads the 'New Season' / 'New Content' banner inside the Group Finder window when it appears."] =
    "Lê o banner 'Nova Temporada' / 'Novo Conteúdo' que aparece dentro da janela do Localizador de Grupos."

L["Debug log (UI Reader)"] = "Log de depuração (UI Reader)"
L["Prints debug information to chat about reading buttons and UI tooltips. Use only to diagnose problems."] =
    "Imprime no chat informações de depuração sobre leitura de botões e tooltips de UI. Use apenas para diagnosticar problemas."

-- Sliders (label / tooltip)
L["Debounce (sec)"] = "Debounce (seg)"
L["Wait time after a tooltip appears before starting to read it. Higher values reduce accidental reads while moving the mouse quickly."] =
    "Tempo de espera após o tooltip aparecer antes de iniciar a leitura. Aumentar reduz leituras acidentais ao mover o mouse rapidamente."

L["Minimum global interval (sec)"] = "Intervalo mínimo global (seg)"
L["Minimum time between two consecutive reads. Prevents overlapping speech when tooltips change rapidly."] =
    "Tempo mínimo entre duas leituras consecutivas. Impede que textos se sobreponham quando tooltips mudam rapidamente."

L["Scan interval (sec)"] = "Scan interval (seg)"
L["How often the addon scans for dynamic tooltips created by other addons. Lower values detect them faster but use more CPU."] =
    "Com que frequência o addon procura tooltips dinâmicos criados por outros addons. Valores menores detectam mais rápido, mas usam mais CPU."

L["Per-owner time lock (sec) (optional)"] = "Lock por tempo (seg) (opcional)"
L["After reading a tooltip, ignore new tooltips from the same owner for this duration. Use 0 to disable. Helps avoid repeats in UIs with frequent events."] =
    "Após ler um tooltip, ignora novos tooltips do mesmo dono por este período. Use 0 para desativar. Útil para evitar repetições em UIs com eventos frequentes."

L["Max lines read per tooltip"] = "Máximo de linhas lidas por tooltip"
L["Caps how many text lines are read per tooltip. Tooltips with many lines (such as complex items) may be truncated for shorter reads."] =
    "Limita quantas linhas de texto são lidas por tooltip. Tooltips com muitas linhas (como itens complexos) podem ser truncados para leituras mais curtas."

-- ===== Keybinding names =====
L["Toggle UiTTS on/off"] = "Ligar/desligar o UiTTS"
L["Stop speaking"] = "Parar a fala"
L["Repeat last spoken text"] = "Repetir o último texto falado"
L["Read current tooltip"] = "Ler o tooltip atual"

-- ===== Tabs / dropdown / quick actions =====
L["Text-to-Speech"] = "Texto para Fala"
L["Accessibility suite for World of Warcraft."] = "Suíte de acessibilidade para World of Warcraft."
L["Open Text-to-Speech"] = "Abrir Texto para Fala"
L["AbleCraft loaded. Use /ablecraft or /uitts config to open options."] = "AbleCraft carregado. Use /ablecraft ou /uitts config para abrir as opções."
L["Tooltips"] = "Tooltips"
L["Experience & performance"] = "Experiência e desempenho"
L["Voice"] = "Voz"
L["Automatic (WoW voice setting)"] = "Automática (configuração de voz do WoW)"
L["Quick actions"] = "Ações rápidas"
L["Enable all reading"] = "Ativar todas as leituras"
L["Disable all reading"] = "Desativar todas as leituras"
L["Test speech (copyable report)"] = "Testar voz (relatório copiável)"

-- ===== Voice output section =====
L["Voice output"] = "Saída de voz"
L["Use custom speech rate/volume"] = "Usar velocidade/volume de fala personalizados"
L["Overrides WoW's chat TTS rate and volume with the values below. When off, UiTTS follows WoW's Text-to-Speech settings."] =
    "Substitui a velocidade e o volume do TTS de chat do WoW pelos valores abaixo. Quando desativado, o UiTTS segue as configurações de Texto-para-Voz do WoW."
L["Speech rate (-10 to 10)"] = "Velocidade da fala (-10 a 10)"
L["Speech speed used when 'Use custom speech rate/volume' is enabled. Negative is slower, positive is faster."] =
    "Velocidade da fala usada quando 'Usar velocidade/volume de fala personalizados' está ativado. Negativo é mais lento, positivo é mais rápido."
L["Speech volume (0 to 100)"] = "Volume da fala (0 a 100)"
L["Speech volume used when 'Use custom speech rate/volume' is enabled."] =
    "Volume da fala usado quando 'Usar velocidade/volume de fala personalizados' está ativado."

-- ===== Chat and events options =====
L["Chat and events"] = "Chat e eventos"
L["Read whispers"] = "Ler sussurros"
L["Reads incoming whispers (player and Battle.net), including the sender's name."] =
    "Lê sussurros recebidos (jogador e Battle.net), incluindo o nome do remetente."
L["Read party chat"] = "Ler chat do grupo"
L["Reads messages in party chat, including the sender's name."] =
    "Lê mensagens no chat do grupo, incluindo o nome do remetente."
L["Read say"] = "Ler falar (say)"
L["Reads nearby 'say' messages, including the speaker's name."] =
    "Lê mensagens de 'falar' (say) próximas, incluindo o nome de quem falou."
L["Read guild chat"] = "Ler chat da guilda"
L["Reads guild chat messages, including the sender's name."] =
    "Lê mensagens do chat da guilda, incluindo o nome do remetente."
L["Read yell"] = "Ler gritar (yell)"
L["Reads nearby 'yell' messages, including the speaker's name."] =
    "Lê mensagens de 'gritar' (yell) próximas, incluindo o nome de quem falou."
L["Read loot messages"] = "Ler mensagens de saque"
L["Reads loot messages such as items and money you receive."] =
    "Lê mensagens de saque, como itens e dinheiro que você recebe."
L["Read target changes"] = "Ler mudança de alvo"
L["Announces the name and level of your target whenever it changes."] =
    "Anuncia o nome e o nível do seu alvo sempre que ele muda."

-- ===== Chat / event runtime strings =====
L["Whisper from %s: %s"] = "Sussurro de %s: %s"
L["Party, %s: %s"] = "Grupo, %s: %s"
L["%s says: %s"] = "%s diz: %s"
L["Guild, %s: %s"] = "Guilda, %s: %s"
L["%s yells: %s"] = "%s grita: %s"
L["Target: %s"] = "Alvo: %s"
L["Target: %s, level %d"] = "Alvo: %s, nível %d"

-- ===== Guide tab =====
L["Guide"] = "Guia"
L["How to use UiTTS"] = "Como usar o UiTTS"
L["Read entire guide"] = "Ler o guia inteiro"
L["Read this section"] = "Ler esta seção"
L["Commands and keybindings"] = "Comandos e atalhos"
L["General"] = "Geral"

L["What is UiTTS?"] = "O que é o UiTTS?"
L["UiTTS reads tooltips and interface text aloud using World of Warcraft's built-in Text-to-Speech engine. It is meant to make the game more accessible: hover something, or open a window, and UiTTS speaks what is there. Use the checkboxes on the Options tab to choose exactly what is read."] =
    "O UiTTS lê tooltips e textos da interface em voz alta usando o motor de Texto-para-Voz embutido no World of Warcraft. Ele foi feito para tornar o jogo mais acessível: passe o mouse sobre algo, ou abra uma janela, e o UiTTS fala o que está ali. Use as caixas de seleção na aba de Opções para escolher exatamente o que é lido."
L["Getting started"] = "Primeiros passos"
L["Everything is on by default except the noisier chat channels. Turn the master switch on or off with the 'Enable UiTTS' option or the slash command /uitts toggle. If speech ever gets stuck, press your Stop keybinding or type /uitts stop."] =
    "Tudo vem ativado por padrão, exceto os canais de chat mais ruidosos. Ligue ou desligue a chave mestra com a opção 'Ativar UiTTS' ou com o comando /uitts toggle. Se a fala travar, use seu atalho de Parar ou digite /uitts stop."
L["Slash commands"] = "Comandos de barra"
L["Type /uitts on to enable, /uitts off to disable, /uitts toggle to switch, /uitts stop to stop speaking, /uitts repeat to hear the last thing spoken again, /uitts config to open the options, and /uitts guide to open this guide."] =
    "Digite /uitts on para ativar, /uitts off para desativar, /uitts toggle para alternar, /uitts stop para parar a fala, /uitts repeat para ouvir de novo a última coisa falada, /uitts config para abrir as opções e /uitts guide para abrir este guia."
L["Keybindings"] = "Atalhos de teclado"
L["In the game's Key Bindings window, under the UiTTS category, you can bind four actions: toggle UiTTS on or off, stop speaking, repeat the last spoken text, and read the tooltip currently under the mouse on demand."] =
    "Na janela de Atalhos do jogo, na categoria UiTTS, você pode configurar quatro ações: ligar/desligar o UiTTS, parar a fala, repetir o último texto falado e ler sob demanda o tooltip que está sob o mouse."

-- ===== Guide: GossipFrame entry =====
L["Reads the NPC greeting text and dialog options when the gossip window opens. Use the speaker icon or press R to restart the read."] =
    "Lê em voz alta o texto de saudação do NPC e as opções de diálogo quando a janela de gossip abre. Use o ícone de alto-falante ou pressione R para reiniciar a leitura."

-- ===== Raid warnings / boss emotes =====
L["Read raid warnings and boss emotes"] = "Ler avisos de raide e emotes de chefe"
L["Reads the large warnings shown at the top center of the screen, such as raid warnings, boss emotes and event announcements."] =
    "Lê em voz alta os avisos grandes exibidos no topo central da tela, como avisos de raide, emotes de chefes e anúncios de eventos."

-- ===== Gossip option hover reading =====
L["NPC dialog options on hover"] = "Opções de diálogo do NPC ao passar o mouse"
L["Reads each dialog option of the gossip window when the mouse hovers over it, including options drawn by skins such as DMHC."] =
    "Lê cada opção de diálogo da janela de gossip quando o mouse passa por cima, incluindo opções desenhadas por skins como o DMHC."
