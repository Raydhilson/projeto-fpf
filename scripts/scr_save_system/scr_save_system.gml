// =======================================================
// 1. SALVAR O PROGRESSO (Funciona na Fogueira e no Pause)
// =======================================================
function salvar_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    
    // SEGURANÇA DO PAUSE: Se o player foi desativado pelo Pause, ativa rapidinho para ler os dados
    var _reativar_pause = false;
    if (!instance_exists(obj_player)) {
        instance_activate_object(obj_player);
        _reativar_pause = true;
    }
    
    ini_open(_arquivo);
    
    // Salva a sala atual pelo nome (mais seguro que o ID numérico)
    ini_write_string("Mundo", "Sala", room_get_name(room));
    ini_write_real("Economia", "Sucata", global.scrap);
    
    // Salva os dados diretos do ratinho
    if (instance_exists(obj_player)) {
        ini_write_real("Player", "X", obj_player.x);
        ini_write_real("Player", "Y", obj_player.y);
        ini_write_real("Player", "HP", obj_player.hp);
        ini_write_real("Player", "Curativos", obj_player.curativo_count);
        ini_write_real("Player", "Molotovs", obj_player.molotov_count);
        ini_write_real("Player", "ArmaNivel", obj_player.arma_nivel);
        ini_write_real("Player", "ArmaXP", obj_player.arma_xp);
    }
    
    ini_close();
    
    // Se estava pausado e só queríamos salvar, desativa o player de novo
    if (_reativar_pause && instance_exists(obj_game_controller) && obj_game_controller.is_paused) {
        instance_deactivate_object(obj_player);
    }
    
    show_debug_message("Jogo salvo com sucesso no " + _arquivo);
}

// =======================================================
// 2. CARREGAR O PROGRESSO (Chamado no Menu Inicial)
// =======================================================
function carregar_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    
    if (file_exists(_arquivo)) {
        ini_open(_arquivo);
        
        var _nome_sala = ini_read_string("Mundo", "Sala", "");
        global.scrap   = ini_read_real("Economia", "Sucata", 0);
        
        // Guarda numa fila global para o obj_player puxar assim que a sala abrir
        global.carregando_save = true;
        global.load_x          = ini_read_real("Player", "X", 0);
        global.load_y          = ini_read_real("Player", "Y", 0);
        global.load_hp         = ini_read_real("Player", "HP", 100);
        global.load_curativos  = ini_read_real("Player", "Curativos", 0);
        global.load_molotovs   = ini_read_real("Player", "Molotovs", 0);
        global.load_arma_nivel = ini_read_real("Player", "ArmaNivel", 1);
        global.load_arma_xp    = ini_read_real("Player", "ArmaXP", 0);
        
        ini_close();
        
        // Vai para a sala salva (ou começa novo jogo se der falha no nome)
        var _id_sala = asset_get_index(_nome_sala);
        if (_id_sala > -1) {
            room_goto(_id_sala);
        } else {
            novo_jogo(_slot);
        }
    } else {
        // Se não existir save ainda, inicia um Novo Jogo direto
        novo_jogo(_slot);
    }
}

// =======================================================
// 3. INICIAR NOVO JOGO DO ZERO
// =======================================================
function novo_jogo(_slot) {
    var _arquivo = "save_" + string(_slot) + ".ini";
    if (file_exists(_arquivo)) {
        file_delete(_arquivo); // Limpa o save antigo daquele slot
    }
    
    global.scrap = 0;
    global.carregando_save = false;
    
    // ATENÇÃO: Confirme se este é o nome exato da sua sala da floresta!
    room_goto(rm_forest_1); 
}