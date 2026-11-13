// =======================================================
// 0. VERIFICAR SE O SAVE EXISTE
// =======================================================
function save_existe(_slot) {
    return file_exists("save_" + string(_slot) + ".ini");
}

// =======================================================
// 1. SALVAR E CARREGAR CONFIGURAÇÕES (config.ini)
// =======================================================
function salvar_configuracoes() {
    ini_open("config.ini");
    
    if (!variable_global_exists("res_index")) global.res_index = 0;
    
    ini_write_real("Video", "Brilho", global.brilho);
    ini_write_string("Geral", "Idioma", global.idioma);
    ini_write_real("Video", "Fullscreen", global.tela_cheia);
    ini_write_real("Video", "ResIndex", global.res_index);
    ini_write_real("Video", "TremerTela", global.tremer_tela);
    
    ini_write_real("Controles", "Direita", global.key_right);
    ini_write_real("Controles", "Esquerda", global.key_left);
    ini_write_real("Controles", "Cima", global.key_up);
    ini_write_real("Controles", "Baixo", global.key_down);
    
    ini_write_real("Controles", "Pulo", global.key_jump);
    ini_write_real("Controles", "Ataque", global.key_attack);
    ini_write_real("Controles", "Esquiva", global.key_roll);
    ini_write_real("Controles", "Cura", global.key_heal);
    ini_write_real("Controles", "Arremesso", global.key_throw);
    ini_write_real("Controles", "Confirmar", global.key_confirm);
    
    ini_close();
    show_debug_message("Configuracoes salvas no config.ini!");
}

function carregar_configuracoes() {
    ini_open("config.ini");
    
    global.brilho      = ini_read_real("Video", "Brilho", 0.5);
    global.idioma      = ini_read_string("Geral", "Idioma", "PT");
    global.tela_cheia  = ini_read_real("Video", "Fullscreen", 0);
    global.res_index   = ini_read_real("Video", "ResIndex", 0);
    global.tremer_tela = ini_read_real("Video", "TremerTela", 1);
    
    // Trava de segurança para o índice de resolução
    if (variable_global_exists("resolucoes")) {
        global.res_index = clamp(global.res_index, 0, array_length(global.resolucoes) - 1);
    }
    
    // Padrão A/D/W/S para o Player 1 não conflitar com as Setas do Player 2
    global.key_right   = ini_read_real("Controles", "Direita", ord("D"));
    global.key_left    = ini_read_real("Controles", "Esquerda", ord("A"));
    global.key_up      = ini_read_real("Controles", "Cima", ord("W"));
    global.key_down    = ini_read_real("Controles", "Baixo", ord("S"));
    
    global.key_jump    = ini_read_real("Controles", "Pulo", vk_space);
    global.key_attack  = ini_read_real("Controles", "Ataque", ord("J"));
    global.key_roll    = ini_read_real("Controles", "Esquiva", ord("K"));
    global.key_heal    = ini_read_real("Controles", "Cura", ord("H"));
    global.key_throw   = ini_read_real("Controles", "Arremesso", ord("F"));
    global.key_confirm = ini_read_real("Controles", "Confirmar", vk_enter);
    
    ini_close();
    window_set_fullscreen(global.tela_cheia);
}

function restaurar_padroes() {
    global.brilho      = 0.5;
    global.idioma      = "PT";
    global.tela_cheia  = 0;
    global.res_index   = 0; // Volta para 1280x720 por padrão
    global.tremer_tela = 1;
    
    global.key_right   = ord("D");
    global.key_left    = ord("A");
    global.key_up      = ord("W");
    global.key_down    = ord("S");
    
    global.key_jump    = vk_space;
    global.key_attack  = ord("J");
    global.key_roll    = ord("K");
    global.key_heal    = ord("H");
    global.key_throw   = ord("F");
    global.key_confirm = vk_enter;
    
    window_set_fullscreen(false);
    salvar_configuracoes();
    show_debug_message("Configuracoes restauradas para o padrao!");
}

// =======================================================
// 2. SALVAR O PROGRESSO (Fogueira e Pause)
// =======================================================
function salvar_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    
    var _reativar_pause = false;
    if (!instance_exists(obj_player)) {
        instance_activate_object(obj_player);
        _reativar_pause = true;
    }
    
    ini_open(_arquivo);
    
    ini_write_string("Mundo", "Sala", room_get_name(room));
    ini_write_real("Economia", "Sucata", global.scrap);
    
    // Busca especificamente o Player 1 (player_id == 0) para salvar os dados principais
    var _p1 = noone;
    with (obj_player) {
        if (!variable_instance_exists(id, "player_id") || player_id == 0) {
            _p1 = id;
        }
    }
    if (_p1 == noone && instance_exists(obj_player)) {
        _p1 = instance_find(obj_player, 0);
    }
    
    if (_p1 != noone) {
        ini_write_real("Player", "X", _p1.x);
        ini_write_real("Player", "Y", _p1.y);
        // Garante que nunca salve HP 0 caso o P1 esteja nocauteado na hora de salvar
        ini_write_real("Player", "HP", max(30, _p1.hp));
        ini_write_real("Player", "Curativos", _p1.curativo_count);
        ini_write_real("Player", "Molotovs", _p1.molotov_count);
        ini_write_real("Player", "Facas", _p1.faca_count);
        ini_write_real("Player", "ArmaNivel", _p1.arma_nivel);
        ini_write_real("Player", "ArmaXP", _p1.arma_xp);
        
        // Materiais Orgânicos
        ini_write_real("Player", "carne", _p1.carne_count);
        ini_write_real("Player", "glandula", _p1.glandula_count);
        ini_write_real("Player", "ferrao", _p1.ferrao_count);
    }
    
    ini_close();
    
    if (_reativar_pause && instance_exists(obj_game_controller) && obj_game_controller.is_paused) {
        instance_deactivate_object(obj_player);
    }
    
    show_debug_message("Jogo salvo com sucesso no " + _arquivo);
}

// =======================================================
// 3. CARREGAR O PROGRESSO (Menu Inicial e Morte)
// =======================================================
function carregar_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    
    if (file_exists(_arquivo)) {
        ini_open(_arquivo);
        
        var _nome_sala = ini_read_string("Mundo", "Sala", "");
        global.scrap   = ini_read_real("Economia", "Sucata", 0);
        
        global.carregando_save = true;
        global.load_x          = ini_read_real("Player", "X", 0);
        global.load_y          = ini_read_real("Player", "Y", 0);
        global.load_hp         = ini_read_real("Player", "HP", 100);
        global.load_curativos  = ini_read_real("Player", "Curativos", 0);
        global.load_molotovs   = ini_read_real("Player", "Molotovs", 0);
        global.load_facas      = ini_read_real("Player", "Facas", 0);
        global.load_arma_nivel = ini_read_real("Player", "ArmaNivel", 1);
        global.load_arma_xp    = ini_read_real("Player", "ArmaXP", 0);
        
        // Materiais Orgânicos Carregados
        global.load_carne      = ini_read_real("Player", "carne", 0);
        global.load_glandula   = ini_read_real("Player", "glandula", 0);
        global.load_ferrao     = ini_read_real("Player", "ferrao", 0);
        
        ini_close();
        
        var _id_sala = asset_get_index(_nome_sala);
        if (_id_sala > -1) {
            room_goto(_id_sala);
        } else {
            novo_jogo(_slot);
        }
    } else {
        novo_jogo(_slot);
    }
}

// =======================================================
// 4. INICIAR NOVO JOGO DO ZERO
// =======================================================
function novo_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    if (file_exists(_arquivo)) {
        file_delete(_arquivo);
    }
    
    global.scrap = 0;
    global.carregando_save = false;
    
    room_goto(rm_forest_1); 
}