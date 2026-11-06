// Alternar Tela Cheia no F11
if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    window_set_fullscreen(global.tela_cheia);
    if (variable_global_exists("salvar_configuracoes")) global.salvar_configuracoes();
}

// ==========================================
// 1. MODO DE REBIND (CAPTURANDO TECLA NOVA)
// ==========================================
if (menu_state == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (menu_index) {
                case 3: global.key_jump   = nova_tecla; break;
                case 4: global.key_attack = nova_tecla; break;
                case 5: global.key_roll   = nova_tecla; break;
                case 6: global.key_heal   = nova_tecla; break;
                case 7: global.key_throw  = nova_tecla; break;
                case 8: global.key_left   = nova_tecla; break;
                case 9: global.key_right  = nova_tecla; break;
            }
            // Salva imediatamente no config.ini!
            if (variable_global_exists("salvar_configuracoes")) {
                global.salvar_configuracoes();
            }
        }
        aguardando_tecla = false;
        keyboard_clear(vk_anykey);
    }
    exit;
}

// ==========================================
// 2. LEITURA DE NAVEGAÇÃO (WASD + Setas + Gamepad)
// ==========================================
var key_up      = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
var key_down    = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
var key_left    = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || gamepad_button_check_pressed(0, gp_padl);
var key_right   = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || gamepad_button_check_pressed(0, gp_padr);
var key_enter   = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
var key_back    = keyboard_check_pressed(vk_escape)|| gamepad_button_check_pressed(0, gp_face2);

// --- ESTADO 0: MENU PRINCIPAL ---
if (menu_state == 0) {
    if (key_up) {
        menu_index--;
        if (menu_index < 0) menu_index = array_length(options) - 1;
        if (menu_index == 1 && !has_save) menu_index = 0; // Pula Continuar se não houver save
    }
    
    if (key_down) {
        menu_index++;
        if (menu_index >= array_length(options)) menu_index = 0;
        if (menu_index == 1 && !has_save) menu_index = 2; // Pula Continuar se não houver save
    }
    
    if (key_enter) {
        switch (options[menu_index]) {
            case "new_game":
                novo_jogo(1);
                break;
                
            case "continue_game":
                if (has_save) carregar_jogo(1);
                break;
                
            case "options":
                menu_state = 1;
                menu_index = 0;
                break;
                
            case "quit":
                game_end();
                break;
        }
    }
}
// --- ESTADO 1: SUB-MENU DE OPÇÕES E CONTROLES ---
else if (menu_state == 1) {
    var total_cfg = 11;
    if (key_up)   { menu_index--; if (menu_index < 0) menu_index = total_cfg - 1; }
    if (key_down) { menu_index++; if (menu_index >= total_cfg) menu_index = 0; }
    
    if (key_back) {
        if (variable_global_exists("salvar_configuracoes")) global.salvar_configuracoes();
        menu_state = 0;
        menu_index = 2; // Volta o cursor para "Opções"
    }
    
    // Permite trocar as 3 primeiras opções tanto no Enter quanto usando A/D ou Setas Esquerda/Direita
    var key_toggle = key_enter || key_left || key_right;
    
    if (key_toggle && menu_index <= 2) {
        switch (menu_index) {
            case 0: // Idioma
                global.idioma = (global.idioma == "PT") ? "EN" : "PT";
                break;
            case 1: // Tela Cheia
                global.tela_cheia = !window_get_fullscreen();
                window_set_fullscreen(global.tela_cheia);
                break;
            case 2: // Tremer Tela
                global.tremer_tela = !global.tremer_tela;
                break;
        }
        if (variable_global_exists("salvar_configuracoes")) global.salvar_configuracoes();
    }
    else if (key_enter && menu_index >= 3) {
        switch (menu_index) {
            case 3: // Pulo
            case 4: // Ataque
            case 5: // Esquiva
            case 6: // Curar
            case 7: // Molotov
            case 8: // Esquerda
            case 9: // Direita
                aguardando_tecla = true;
                keyboard_clear(vk_anykey);
                break;
            case 10: // Voltar e Salvar
                if (variable_global_exists("salvar_configuracoes")) global.salvar_configuracoes();
                menu_state = 0;
                menu_index = 2;
                break;
        }
    }
}