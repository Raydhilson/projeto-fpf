// =======================================================
// 0. VERIFICAR SE O SAVE EXISTE E APLICAR RESOLUÇÃO
// =======================================================
function save_existe(_slot) {
    return file_exists("save_" + string(_slot) + ".ini");
}

function aplicar_resolucao() {
    if (!variable_global_exists("res_index")) global.res_index = 0;
    
    var _larguras = [1280, 1600, 1920];
    var _alturas  = [720,  900,  1080];
    
    var _idx = clamp(global.res_index, 0, 2);
    var _w = _larguras[_idx];
    var _h = _alturas[_idx];
    
    window_set_fullscreen(global.tela_cheia);
    
    // Se estiver em modo janela, altera o tamanho e centraliza no monitor
    if (!window_get_fullscreen()) {
        window_set_size(_w, _h);
        window_center();
    }
    
    // Mantém a superfície de renderização nítida
    if (surface_exists(application_surface)) {
        surface_resize(application_surface, _w, _h);
    }
}

// =======================================================
// 1. SALVAR E CARREGAR CONFIGURAÇÕES (config.ini)
// =======================================================
function salvar_configuracoes() {
    ini_open("config.ini");
    
    ini_write_string("Geral", "Idioma", global.idioma);
    ini_write_real("Video", "Brilho", global.brilho);
    ini_write_real("Video", "Fullscreen", global.tela_cheia);
    ini_write_real("Video", "ResolucaoIndex", variable_global_exists("res_index") ? global.res_index : 0);
    ini_write_real("Video", "TremerTela", global.tremer_tela);
    ini_write_real("Audio", "Master", variable_global_exists("vol_master") ? global.vol_master : 1.0);
    
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
    if (file_exists("config.ini")) {
        ini_open("config.ini");
        
        global.idioma      = ini_read_string("Geral", "Idioma", "PT");
        global.brilho      = ini_read_real("Video", "Brilho", 0.5);
        global.tela_cheia  = ini_read_real("Video", "Fullscreen", 0);
        global.res_index   = ini_read_real("Video", "ResolucaoIndex", 0);
        global.tremer_tela = ini_read_real("Video", "TremerTela", 1);
        global.vol_master  = ini_read_real("Audio", "Master", 1.0);
        
        global.key_right   = ini_read_real("Controles", "Direita", vk_right);
        global.key_left    = ini_read_real("Controles", "Esquerda", vk_left);
        global.key_up      = ini_read_real("Controles", "Cima", vk_up);
        global.key_down    = ini_read_real("Controles", "Baixo", vk_down);
        
        global.key_jump    = ini_read_real("Controles", "Pulo", vk_space);
        global.key_attack  = ini_read_real("Controles", "Ataque", ord("J"));
        global.key_roll    = ini_read_real("Controles", "Esquiva", ord("K"));
        global.key_heal    = ini_read_real("Controles", "Cura", ord("H"));
        global.key_throw   = ini_read_real("Controles", "Arremesso", ord("F"));
        global.key_confirm = ini_read_real("Controles", "Confirmar", vk_enter);
        
        ini_close();
    }
    
    aplicar_resolucao();
    if (variable_global_exists("vol_master")) {
        audio_master_gain(global.vol_master);
    }
}

function restaurar_padroes() {
    global.brilho      = 0.5;
    global.idioma      = "PT";
    global.tela_cheia  = 0;
    global.res_index   = 0;
    global.tremer_tela = 1;
    global.vol_master  = 1.0;
    
    global.key_right   = vk_right;
    global.key_left    = vk_left;
    global.key_up      = vk_up;
    global.key_down    = vk_down;
    
    global.key_jump    = vk_space;
    global.key_attack  = ord("J");
    global.key_roll    = ord("K");
    global.key_heal    = ord("H");
    global.key_throw   = ord("F");
    global.key_confirm = vk_enter;
    
    aplicar_resolucao();
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
    
    if (instance_exists(obj_player)) {
        ini_write_real("Player", "X", obj_player.x);
        ini_write_real("Player", "Y", obj_player.y);
        ini_write_real("Player", "HP", obj_player.hp);
        ini_write_real("Player", "Curativos", obj_player.curativo_count);
        ini_write_real("Player", "Molotovs", obj_player.molotov_count);
        ini_write_real("Player", "Facas", obj_player.faca_count);
        ini_write_real("Player", "ArmaNivel", obj_player.arma_nivel);
        ini_write_real("Player", "ArmaXP", obj_player.arma_xp);
        
        // Materiais Orgânicos
        ini_write_real("Player", "carne", obj_player.carne_count);
        ini_write_real("Player", "glandula", obj_player.glandula_count);
        ini_write_real("Player", "ferrao", obj_player.ferrao_count);
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
            // TRANSIÇÃO SUAVE AO CARREGAR SAVE (USANDO OBJ_TRANSITION)
            if (asset_get_index("obj_transition") != -1 && !instance_exists(obj_transition)) {
                var t = instance_create_layer(0, 0, layer, obj_transition);
                t.destino_room = _id_sala;
                t.estado = 1;
            } else {
                room_goto(_id_sala);
            }
        } else {
            novo_jogo(_slot);
        }
    } else {
        novo_jogo(_slot);
    }
}

// =======================================================
// 4. INICIAR NOVO JOGO DO ZERO (COM TRANSIÇÃO SUAVE)
// =======================================================
function novo_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    if (file_exists(_arquivo)) {
        file_delete(_arquivo);
    }
    
    global.scrap = 0;
    global.carregando_save = false;
    
    // TRANSIÇÃO SUAVE PARA A PRIMEIRA FASE (USANDO OBJ_TRANSITION)
    if (asset_get_index("obj_transition") != -1 && !instance_exists(obj_transition)) {
        var t = instance_create_layer(0, 0, layer, obj_transition);
        t.destino_room = rm_forest_1;
        t.estado = 1;
    } else {
        room_goto(rm_forest_1);
    }
}