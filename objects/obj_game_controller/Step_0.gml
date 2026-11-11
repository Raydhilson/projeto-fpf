// Alternar entre Tela Cheia e Modo Janela no F11
if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    window_set_fullscreen(global.tela_cheia);
    salvar_configuracoes();
}

// ==========================================
// 1. MODO DE REBIND (CAPTURANDO TECLA NOVA)
// ==========================================
if (is_paused && pause_state == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (pause_index) {
                case 4:  global.key_jump   = nova_tecla; break;
                case 5:  global.key_attack = nova_tecla; break;
                case 6:  global.key_roll   = nova_tecla; break;
                case 7:  global.key_heal   = nova_tecla; break;
                case 8:  global.key_throw  = nova_tecla; break;
                case 9:  global.key_left   = nova_tecla; break;
                case 10: global.key_right  = nova_tecla; break;
            }
            salvar_configuracoes();
        }
        aguardando_tecla = false;
        keyboard_clear(vk_anykey);
    }
    exit;
}

// ==========================================
// 2. GATILHO DO PAUSE (Botão ESC ou Start)
// ==========================================
var key_pause = keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start);

if (key_pause) {
    if (!is_paused) {
        // Abre o menu de pausa
        is_paused = true;
        pause_state = 0;
        pause_index = 0;
        aguardando_tecla = false;
        instance_deactivate_all(true);
    } else {
        // Se estiver nas Opções (Tela 1), o ESC volta para a Tela 0 e salva!
        if (pause_state == 1) {
            salvar_configuracoes();
            pause_state = 0;
            pause_index = 1; // Devolve o cursor em "OPCOES E CONTROLES"
        } else {
            // Se estiver na Tela 0, o ESC despausa o jogo!
            is_paused = false;
            instance_activate_all();
        }
    }
    exit; // Impede que o clique do ESC conflite com a navegação no mesmo frame
}

// ==========================================
// 3. NAVEGAÇÃO DO MENU DE PAUSA
// ==========================================
if (is_paused) {
    var key_up      = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(global.key_up)    || gamepad_button_check_pressed(0, gp_padu);
    var key_down    = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || keyboard_check_pressed(global.key_down)  || gamepad_button_check_pressed(0, gp_padd);
    var key_left    = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(global.key_left)  || gamepad_button_check_pressed(0, gp_padl);
    var key_right   = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(global.key_right) || gamepad_button_check_pressed(0, gp_padr);
    var key_confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);
    
    // --- TELA 0: MENU DE PAUSE PRINCIPAL ---
    if (pause_state == 0) {
        var total_opcoes = 3;
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes - 1; }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes) pause_index = 0; }
        
        if (key_confirm) {
            if (pause_index == 0) {
                is_paused = false;
                instance_activate_all();
            } else if (pause_index == 1) {
                pause_state = 1;
                pause_index = 0;
            } else if (pause_index == 2) {
                salvar_jogo(1);
                salvar_configuracoes();
                
                is_paused = false;
                instance_activate_all();
                room_goto(rm_main_menu); 
            }
        }
    }
    // --- TELA 1: SUB-MENU DE OPÇÕES E REBIND (13 Opções: 0 a 12) ---
    else if (pause_state == 1) {
        var total_opcoes_cfg = 13; // 0 a 12 (Corrigido para bater com os 13 itens do Draw GUI!)
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes_cfg - 1; }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes_cfg) pause_index = 0; }
        
        var key_toggle = key_confirm || key_left || key_right;
        
        if (key_toggle && pause_index <= 2) {
            switch (pause_index) {
                case 0: global.idioma = (global.idioma == "PT") ? "EN" : "PT"; break;
                case 1:
                    global.tela_cheia = !window_get_fullscreen();
                    window_set_fullscreen(global.tela_cheia);
                    break;
                case 2: global.tremer_tela = !global.tremer_tela; break;
            }
            salvar_configuracoes();
        }
        else if (pause_index == 3 && (key_left || key_right || key_confirm)) {
            if (key_left) global.brilho = clamp(global.brilho - 0.1, 0.1, 1.0);
            if (key_right || key_confirm) {
                global.brilho += 0.1;
                if (global.brilho > 1.0) global.brilho = 0.1;
            }
            salvar_configuracoes();
        }
        else if (key_confirm && pause_index >= 4) {
            if (pause_index >= 4 && pause_index <= 10) {
                aguardando_tecla = true;
                keyboard_clear(vk_anykey);
            } else if (pause_index == 11) {
                restaurar_padroes();
            } else if (pause_index == 12) {
                salvar_configuracoes();
                pause_state = 0;
                pause_index = 1;
            }
        }
    }
}