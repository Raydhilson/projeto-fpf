// Alternar entre Tela Cheia e Modo Janela no F11
if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    window_set_fullscreen(global.tela_cheia);
}

// ==========================================
// 1. MODO DE REBIND (CAPTURANDO TECLA NOVA)
// ==========================================
if (is_paused && pause_state == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        
        // Se apertar ESC, cancela a troca. Se for outra tecla válida, grava!
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (pause_index) {
                case 3: global.key_jump   = nova_tecla; break;
                case 4: global.key_attack = nova_tecla; break;
                case 5: global.key_roll   = nova_tecla; break;
                case 6: global.key_heal   = nova_tecla; break;
                case 7: global.key_throw  = nova_tecla; break;
                case 8: global.key_left   = nova_tecla; break;
                case 9: global.key_right  = nova_tecla; break;
            }
            if (script_exists(asset_get_index("salvar_configuracoes"))) {
                salvar_configuracoes();
            }
        }
        aguardando_tecla = false;
        keyboard_clear(vk_anykey); // Evita que o Enter/W/S dispare o menu no mesmo frame
    }
    exit; // Para o código aqui enquanto espera a tecla!
}

// ==========================================
// 2. GATILHO DO PAUSE (Botão ESC ou Start)
// ==========================================
var key_pause = keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start);

if (key_pause) {
    if (!is_paused) {
        is_paused = true;
        pause_state = 0;
        pause_index = 0;
        instance_deactivate_all(true); // Congela o jogo
    } else {
        // Se estiver nas Opções, o ESC volta pro Pause Principal e salva
        if (pause_state == 1) {
            if (script_exists(asset_get_index("salvar_configuracoes"))) salvar_configuracoes();
            pause_state = 0;
            pause_index = 1;
        } else {
            is_paused = false;
            instance_activate_all(); // Descongela o jogo
        }
    }
}

// ==========================================
// 3. NAVEGAÇÃO DO MENU (Setas + WASD + Gamepad)
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
                // Continuar
                is_paused = false;
                instance_activate_all();
            } else if (pause_index == 1) {
                // Abre Sub-menu de Opções e Controles
                pause_state = 1;
                pause_index = 0;
            } else if (pause_index == 2) {
                // Volta para a capa do jogo e SALVA (Save Híbrido!)
                if (script_exists(asset_get_index("salvar_jogo"))) salvar_jogo(1);
                if (script_exists(asset_get_index("salvar_configuracoes"))) salvar_configuracoes();
                
                is_paused = false;
                instance_activate_all();
                room_goto(rm_main_menu); 
            }
        }
    }
    // --- TELA 1: SUB-MENU DE OPÇÕES E REBIND ---
    else if (pause_state == 1) {
        var total_opcoes_cfg = 11; // 0 a 10
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes_cfg - 1; }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes_cfg) pause_index = 0; }
        
        // Permite trocar as 3 primeiras opções (Idioma, Tela Cheia, Shake) tanto no Enter quanto no A/D ou Setas!
        var key_toggle = key_confirm || key_left || key_right;
        
        if (key_toggle && pause_index <= 2) {
            switch (pause_index) {
                case 0: // Trocar Idioma
                    global.idioma = (global.idioma == "PT") ? "EN" : "PT";
                    break;
                case 1: // Tela Cheia
                    global.tela_cheia = !window_get_fullscreen();
                    window_set_fullscreen(global.tela_cheia);
                    break;
                case 2: // Tremer Tela (Screen Shake)
                    global.tremer_tela = !global.tremer_tela;
                    break;
            }
        }
        else if (key_confirm && pause_index >= 3) {
            switch (pause_index) {
                case 3: // Pulo
                case 4: // Ataque
                case 5: // Esquiva / Roll
                case 6: // Curar
                case 7: // Arremessar Molotov
                case 8: // Andar Esquerda
                case 9: // Andar Direita
                    aguardando_tecla = true;
                    keyboard_clear(vk_anykey);
                    break;
                case 10: // Voltar e Salvar no .ini
                    if (script_exists(asset_get_index("salvar_configuracoes"))) salvar_configuracoes();
                    pause_state = 0;
                    pause_index = 1;
                    break;
            }
        }
    }
}