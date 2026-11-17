display_set_gui_size(800, 450);

// ==========================================
// DECLARAÇÃO OBRIGATÓRIA DE PAUSE E CÂMERA
// ==========================================
is_paused = false;
pause_state = 0; // 0 = Pause Principal | 1 = Opções e Controles
pause_index = 0;
opcao_aba = 0;
aguardando_tecla = false;
hitstop_timer = 0;
shake_magnitude = 0;
shake_fade = 0.4;

pause_opcoes = ["CONTINUAR", "OPCOES / CONTROLES", "VOLTAR AO MENU INICIAL"];

// ==========================================
// SEGURANÇA DE VARIÁVEIS GLOBAIS (FALLBACK)
// ==========================================
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
// =======================================================
// ESTRUTURA AUTOMÁTICA DAS 3 SALAS (TUTORIAL, BICHOS, BOSS)
// =======================================================
if (room == rm_forest_1) {
    // SALA 1: TUTORIAL (Remove os inimigos e o Boss para o jogador testar os controles em paz)
    with (obj_boss_centopeia) instance_destroy();
    with (obj_enemy) instance_destroy();
    with (obj_vespa) instance_destroy();
    
    // Garante que haja um boneco de treino (dummy) e uma fogueira para avançar
    if (!instance_exists(obj_dummy) && instance_exists(obj_player)) {
        instance_create_depth(obj_player.x + 180, obj_player.y, 0, obj_dummy);
    }
    if (!instance_exists(obj_fogueira) && instance_exists(obj_player)) {
        instance_create_depth(obj_player.x + 380, obj_player.y, 0, obj_fogueira);
    }
}
else if (room == rm_forest_2 || room == rm_forest_3) {
    // Monta o cenário básico automaticamente caso a room esteja vazia no editor
    if (!instance_exists(obj_colisor)) {
        var _chao = instance_create_depth(0, 672, 0, obj_colisor);
        _chao.image_xscale = 45;
        _chao.image_yscale = 3;
        
        var _p_esq = instance_create_depth(-32, 0, 0, obj_colisor);
        _p_esq.image_yscale = 25;
        
        var _p_dir = instance_create_depth(1366, 0, 0, obj_colisor);
        _p_dir.image_yscale = 25;
    }
    if (!instance_exists(obj_player)) {
        instance_create_depth(140, 600, 0, obj_player);
    }
    if (!instance_exists(obj_camera)) {
        instance_create_depth(0, 0, 0, obj_camera);
    }
    
    if (room == rm_forest_2) {
        // SALA 2: SALA SÓ COM OS BICHOS (Besouros + Vespa + Fogueira no final)
        with (obj_boss_centopeia) instance_destroy();
        if (!instance_exists(obj_enemy)) {
            instance_create_depth(500, 580, 0, obj_enemy);
            instance_create_depth(850, 580, 0, obj_enemy);
        }
        if (!instance_exists(obj_vespa)) {
            instance_create_depth(680, 470, 0, obj_vespa);
        }
        if (!instance_exists(obj_fogueira)) {
            instance_create_depth(1200, 640, 0, obj_fogueira);
        }
    }
    else if (room == rm_forest_3) {
        // SALA 3: SALA SÓ PARA O BOSS FINAL (Centopeia Alfa)
        with (obj_enemy) instance_destroy();
        with (obj_vespa) instance_destroy();
        if (!instance_exists(obj_boss_centopeia)) {
            instance_create_depth(900, 560, 0, obj_boss_centopeia);
        }
    }
}