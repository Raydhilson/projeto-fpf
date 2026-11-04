// Verifica se um slot específico tem um jogo salvo (Útil para acender o botão "Continue")
function save_existe(slot) {
    var nome_arquivo = "save_slot_" + string(slot) + ".ini";
    return file_exists(nome_arquivo);
}

// Salva o progresso atual em um slot (1, 2 ou 3)
function salvar_jogo(slot) {
    var nome_arquivo = "save_slot_" + string(slot) + ".ini";
    
    ini_open(nome_arquivo);
    
    // Salva a sala e posição
    ini_write_real("Localizacao", "Room", room);
    if (instance_exists(obj_player)) {
        ini_write_real("Localizacao", "X", obj_player.x);
        ini_write_real("Localizacao", "Y", obj_player.y);
        
        // Salva os status do Rato
        ini_write_real("Status", "HP", obj_player.hp);
        ini_write_real("Status", "NivelArma", obj_player.arma_nivel);
        ini_write_real("Inventario", "Curativos", obj_player.curativo_count);
        ini_write_real("Inventario", "Molotovs", obj_player.molotov_count);
    }
    
    // Salva recursos globais
    ini_write_real("Global", "Sucata", global.scrap);
    
    ini_close();
    show_debug_message("Jogo salvo no Slot " + string(slot));
}

// Carrega o progresso de um slot específico
function carregar_jogo(slot) {
    var nome_arquivo = "save_slot_" + string(slot) + ".ini";
    
    if (file_exists(nome_arquivo)) {
        ini_open(nome_arquivo);
        
        // Carrega dados globais
        global.scrap = ini_read_real("Global", "Sucata", 0);
        
        // Vai para a sala salva
        var sala_salva = ini_read_real("Localizacao", "Room", room);
        if (room != sala_salva) {
            room_goto(sala_salva);
        }
        
        // Aplica os status no jogador (se ele já existir na sala)
        if (instance_exists(obj_player)) {
            obj_player.x = ini_read_real("Localizacao", "X", obj_player.x);
            obj_player.y = ini_read_real("Localizacao", "Y", obj_player.y);
            obj_player.hp = ini_read_real("Status", "HP", obj_player.hp_max);
            obj_player.arma_nivel = ini_read_real("Status", "NivelArma", 1);
            obj_player.curativo_count = ini_read_real("Inventario", "Curativos", 0);
            obj_player.molotov_count = ini_read_real("Inventario", "Molotovs", 0);
        }
        
        ini_close();
        show_debug_message("Jogo carregado do Slot " + string(slot));
    } else {
        show_debug_message("Erro: Slot " + string(slot) + " vazio.");
    }
}