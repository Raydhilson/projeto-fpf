display_set_gui_size(800, 450);
persistent = true;

is_paused = false;
pause_state = 0;
pause_index = 0;
opcao_aba = 0;
aguardando_tecla = false;

// Estado de Fim de Jogo e Motivo (0 = Vivo, 1 = Morreu, 2 = Portão Quebrou, 3 = Time Out)
is_dead = false;
motivo_derrota = 0;
death_index = 0;
death_alpha = 0;

// =======================================================
// PORTÃO DO LABORATÓRIO, WAVES E PLACAR TOP 5 DA MOSTRA
// =======================================================
portao_x = 120; // Posição X do Portão na esquerda da sua room (ajuste se quiser!)
portao_hp_max = 200;
portao_hp = portao_hp_max;
portao_piscar = 0;

if (!variable_global_exists("score_atual")) global.score_atual = 0;
tempo_sobrevivido_frames = 0;

wave_atual = 0;
wave_timer = 0;
wave_timer_max = 45 * 60;
wave_cooldown = 180; // 3s antes da primeira wave

// Carrega Top 5 da Mostra
top_scores = [0, 0, 0, 0, 0];
top_tempos = [0, 0, 0, 0, 0];
top_waves  = [0, 0, 0, 0, 0];
score_registrado = false;

if (file_exists("ranking_mostra.ini")) {
    ini_open("ranking_mostra.ini");
    for (var i = 0; i < 5; i++) {
        top_scores[i] = ini_read_real("Top5", "Score_" + string(i), 0);
        top_tempos[i] = ini_read_real("Top5", "Tempo_" + string(i), 0);
        top_waves[i]  = ini_read_real("Top5", "Wave_" + string(i), 0);
    }
    ini_close();
}

// Cartas estilo Arena LoL
escolhendo_carta = false;
carta_index = 1;
cartas_opcoes = [0, 1, 2];

catalogo_cartas = [
    { nome_pt: "SEDE DE SANGUE",        nome_en: "BLOODLUST",        desc_pt: "+5 Dano Base na Lanca\n+20 HP no Rato",               desc_en: "+5 Base Spear DMG\n+20 Player HP",         cor: make_color_rgb(220, 55, 65) },
    { nome_pt: "TURBILHAO AFIADO",      nome_en: "SHARP WHIRLWIND",  desc_pt: "-3s Cooldown no Giro\n+50% Dano no Golpe Giratorio",  desc_en: "-3s Spin Cooldown\n+50% Spin Attack DMG",  cor: make_color_rgb(245, 195, 65) },
    { nome_pt: "BARRICADA REFORCADA",   nome_en: "REINFORCED GATE",  desc_pt: "+80 HP Max no Portao\nConserta +100 HP do Portao",    desc_en: "+80 Gate Max HP\nRepairs +100 Gate HP",    cor: make_color_rgb(65, 185, 245) },
    { nome_pt: "CARAPACA DE RATO",      nome_en: "RAT CARAPACE",     desc_pt: "+35 HP Maximo no Player\nCura +50 HP agora",          desc_en: "+35 Max HP\nHeals +50 HP now",             cor: make_color_rgb(80, 215, 105) },
    { nome_pt: "PIROTECNIA DA ESTUFA",  nome_en: "GREENHOUSE PYRO",  desc_pt: "Lanca em Chamas por 30s\n+2 Coqueteis Molotov",       desc_en: "Flaming Spear 30s\n+2 Molotovs",           cor: make_color_rgb(255, 130, 40) },
    { nome_pt: "CONTRABANDO DE SUCATA", nome_en: "SCRAP SMUGGLING",  desc_pt: "+8 Sucatas Imediatas\n+3 Facas e +1 Curativo",        desc_en: "+8 Instant Scrap\n+3 Knives & +1 Bandage", cor: make_color_rgb(180, 110, 245) }
];

hitstop_timer = 0;
shake_magnitude = 0;
shake_fade = 0.4;

pause_opcoes = ["CONTINUAR", "OPCOES / CONTROLES", "VOLTAR AO MENU INICIAL"];

if (!variable_global_exists("brilho"))        global.brilho        = 0.5;
if (!variable_global_exists("idioma"))        global.idioma        = "PT";
if (!variable_global_exists("tremer_tela"))   global.tremer_tela   = 1;
if (!variable_global_exists("tela_cheia"))    global.tela_cheia    = window_get_fullscreen();
if (!variable_global_exists("res_index"))     global.res_index     = 0;
if (!variable_global_exists("vol_master"))    global.vol_master    = 1.0;
if (!variable_global_exists("vol_sfx"))       global.vol_sfx       = 0.85;

if (!variable_global_exists("key_jump"))      global.key_jump      = vk_space;
if (!variable_global_exists("key_attack"))    global.key_attack    = ord("J");
if (!variable_global_exists("key_roll"))      global.key_roll      = ord("K");
if (!variable_global_exists("key_heal"))      global.key_heal      = ord("H");
if (!variable_global_exists("key_throw"))     global.key_throw     = ord("F");
if (!variable_global_exists("key_spin"))      global.key_spin      = ord("L");
if (!variable_global_exists("key_right"))     global.key_right     = vk_right;
if (!variable_global_exists("key_left"))      global.key_left      = vk_left;
if (!variable_global_exists("key_up"))        global.key_up        = vk_up;
if (!variable_global_exists("key_down"))      global.key_down      = vk_down;
if (!variable_global_exists("key_confirm"))   global.key_confirm   = vk_enter;
if (!variable_global_exists("key_menu"))      global.key_menu      = ord("I");
if (!variable_global_exists("key_tab_left"))  global.key_tab_left  = ord("Q");
if (!variable_global_exists("key_tab_right")) global.key_tab_right = ord("E");

gpu_set_tex_filter(false);

if (file_exists("config.ini")) {
    carregar_configuracoes();
}

audio_master_gain(global.vol_master);

registrar_no_ranking = function() {
    if (score_registrado) return;
    score_registrado = true;
    
    var _seg_totais = floor(tempo_sobrevivido_frames / 60);
    for (var i = 0; i < 5; i++) {
        if (global.score_atual > top_scores[i]) {
            for (var j = 4; j > i; j--) {
                top_scores[j] = top_scores[j - 1];
                top_tempos[j] = top_tempos[j - 1];
                top_waves[j]  = top_waves[j - 1];
            }
            top_scores[i] = global.score_atual;
            top_tempos[i] = _seg_totais;
            top_waves[i]  = wave_atual;
            break;
        }
    }
    
    ini_open("ranking_mostra.ini");
    for (var k = 0; k < 5; k++) {
        ini_write_real("Top5", "Score_" + string(k), top_scores[k]);
        ini_write_real("Top5", "Tempo_" + string(k), top_tempos[k]);
        ini_write_real("Top5", "Wave_" + string(k), top_waves[k]);
    }
    ini_close();
};

nome_tecla = function(_k) {
    var _pt = (global.idioma == "PT");
    switch (_k) {
        case vk_space:     return _pt ? "ESPACO" : "SPACE";
        case vk_up:        return _pt ? "SETA CIMA" : "UP ARROW";
        case vk_down:      return _pt ? "SETA BAIXO" : "DOWN ARROW";
        case vk_left:      return _pt ? "SETA ESQ" : "LEFT ARROW";
        case vk_right:     return _pt ? "SETA DIR" : "RIGHT ARROW";
        case vk_enter:     return "ENTER";
        case vk_shift:     return "SHIFT";
        case vk_control:   return "CTRL";
        case vk_alt:       return "ALT";
        case vk_tab:       return "TAB";
        case vk_backspace: return "BACKSPACE";
        default:
            if (_k >= 48 && _k <= 90) return chr(_k);
            return "KEY " + string(_k);
    }
};