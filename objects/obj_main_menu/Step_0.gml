// Alternar Tela Cheia no F11
if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    aplicar_resolucao();
    salvar_configuracoes();
}

// ==========================================
// 1. MODO DE REBIND (CAPTURANDO TECLA NOVA)
// ==========================================
if (menu_state == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (menu_index) {
                case 5:  global.key_jump   = nova_tecla; break;
                case 6:  global.key_attack = nova_tecla; break;
                case 7:  global.key_roll   = nova_tecla; break;
                case 8:  global.key_heal   = nova_tecla; break;
                case 9:  global.key_throw  = nova_tecla; break;
                case 10: global.key_left   = nova_tecla; break;
                case 11: global.key_right  = nova_tecla; break;
            }
            salvar_configuracoes();
        }
        aguardando_tecla = false;
        keyboard_clear(vk_anykey);
    }
    exit;
}

// ==========================================
// 2. LEITURA DE NAVEGAÇÃO (WASD + Setas + Gamepad)
// ==========================================
var key_up    = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
var key_down  = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
var key_left  = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || gamepad_button_check_pressed(0, gp_padl);
var key_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || gamepad_button_check_pressed(0, gp_padr);
var key_enter = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
var key_back  = keyboard_check_pressed(vk_escape)|| gamepad_button_check_pressed(0, gp_face2);

// --- ESTADO 0: MENU PRINCIPAL ---
if (menu_state == 0) {
    if (key_up) {
        menu_index--;
        if (menu_index < 0) menu_index = array_length(options) - 1;
        if (menu_index == 1 && !has_save) menu_index = 0;
    }
    
    if (key_down) {
        menu_index++;
        if (menu_index >= array_length(options)) menu_index = 0;
        if (menu_index == 1 && !has_save) menu_index = 2;
    }
    
    if (key_enter) {
        switch (options[menu_index]) {
            case "new_game":      novo_jogo(1); break;
            case "continue_game": if (has_save) carregar_jogo(1); break;
            case "options":       menu_state = 1; menu_index = 0; break;
            case "quit":          game_end(); break;
        }
    }
}
// --- ESTADO 1: SUB-MENU DE OPÇÕES E CONTROLES (14 Opções: 0 a 13) ---
else if (menu_state == 1) {
    var total_cfg = 14; // 0 a 13
    if (key_up)   { menu_index--; if (menu_index < 0) menu_index = total_cfg - 1; }
    if (key_down) { menu_index++; if (menu_index >= total_cfg) menu_index = 0; }
    
    if (key_back) {
        salvar_configuracoes();
        menu_state = 0;
        menu_index = 2;
    }
    
    var key_toggle = key_enter || key_left || key_right;
    
    // Opções 0, 1 e 3 (Idioma, Tela Cheia, Tremor de Tela)
    if (key_toggle && (menu_index == 0 || menu_index == 1 || menu_index == 3)) {
        switch (menu_index) {
            case 0: global.idioma = (global.idioma == "PT") ? "EN" : "PT"; break;
            case 1:
                global.tela_cheia = !window_get_fullscreen();
                aplicar_resolucao();
                break;
            case 3: global.tremer_tela = !global.tremer_tela; break;
        }
        salvar_configuracoes();
    }
    // Opção 2: Resolução da Tela
    else if (menu_index == 2 && key_toggle) {
        var _total_res = array_length(global.resolucoes);
        if (key_left) {
            global.res_index--;
            if (global.res_index < 0) global.res_index = _total_res - 1;
        } else if (key_right || key_enter) {
            global.res_index++;
            if (global.res_index >= _total_res) global.res_index = 0;
        }
        aplicar_resolucao();
        salvar_configuracoes();
    }
    // Opção 4: Nível de Brilho
    else if (menu_index == 4 && key_toggle) {
        if (key_left) global.brilho = clamp(global.brilho - 0.1, 0.1, 1.0);
        if (key_right || key_enter) {
            global.brilho += 0.1;
            if (global.brilho > 1.0) global.brilho = 0.1;
        }
        salvar_configuracoes();
    }
    // Opções 5 a 13: Rebind de Teclas, Restaurar Padrões e Voltar
    else if (key_enter && menu_index >= 5) {
        if (menu_index >= 5 && menu_index <= 11) {
            aguardando_tecla = true;
            keyboard_clear(vk_anykey);
        } else if (menu_index == 12) {
            restaurar_padroes();
            aplicar_resolucao();
        } else if (menu_index == 13) {
            salvar_configuracoes();
            menu_state = 0;
            menu_index = 2;
        }
    }
}