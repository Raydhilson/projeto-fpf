if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    aplicar_resolucao();
    salvar_configuracoes();
}

// ==========================================
// 1. MODO DE REBIND (CAPTURANDO TECLA NOVA)
// ==========================================
if (is_paused && pause_state == 1 && opcao_aba == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (pause_index) {
                case 0:  global.key_jump   = nova_tecla; break;
                case 1:  global.key_attack = nova_tecla; break;
                case 2:  global.key_roll   = nova_tecla; break;
                case 3:  global.key_heal   = nova_tecla; break;
                case 4:  global.key_throw  = nova_tecla; break;
                case 5:  global.key_left   = nova_tecla; break;
                case 6:  global.key_right  = nova_tecla; break;
            }
            salvar_configuracoes();
            tocar_sfx("snd_ui_confirm");
        }
        aguardando_tecla = false;
        keyboard_clear(vk_anykey);
    }
    exit;
}

// ==========================================
// 2. GATILHO DO PAUSE (Botão ESC ou Select)
// ==========================================
var key_pause = keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_select);

if (key_pause) {
    if (instance_exists(obj_player) && (obj_player.state == player_state.menu || obj_player.state == player_state.craft)) {
        exit; 
    }

    if (!is_paused) {
        is_paused = true;
        pause_state = 0;
        pause_index = 0;
        aguardando_tecla = false;
        instance_deactivate_all(true);
        tocar_sfx("snd_ui_move");
    } else {
        if (pause_state == 1) {
            salvar_configuracoes();
            pause_state = 0;
            pause_index = 1; 
            tocar_sfx("snd_ui_back");
        } else {
            is_paused = false;
            instance_activate_all();
            tocar_sfx("snd_ui_back");
        }
    }
    keyboard_clear(vk_escape);
    exit; 
}

// ==========================================
// 3. NAVEGAÇÃO DO MENU DE PAUSE
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
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes - 1; tocar_sfx("snd_ui_move"); }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes) pause_index = 0; tocar_sfx("snd_ui_move"); }
        
        if (key_confirm) {
            tocar_sfx("snd_ui_confirm");
            if (pause_index == 0) {
                is_paused = false;
                instance_activate_all();
            } else if (pause_index == 1) {
                pause_state = 1;
                opcao_aba = 0;
                pause_index = 0;
            } else if (pause_index == 2) {
                var _slot = variable_global_exists("slot_atual") ? global.slot_atual : 1;
                salvar_jogo(_slot);
                salvar_configuracoes();
                
                is_paused = false;
                instance_activate_all();
                
                if (asset_get_index("obj_transition") != -1 && !instance_exists(obj_transition)) {
                    var t = instance_create_layer(0, 0, layer, obj_transition);
                    t.persistent = true;
                    t.destino_room = rm_main_menu;
                    t.estado = 1;
                } else {
                    room_goto(rm_main_menu);
                }
            }
        }
    }
    // --- TELA 1: OPÇÕES COM ABAS SEPARADAS ---
    else if (pause_state == 1) {
        if (!variable_instance_exists(id, "opcao_aba")) opcao_aba = 0;
        
        var tab_l = keyboard_check_pressed(global.key_tab_left)  || gamepad_button_check_pressed(0, gp_shoulderl);
        var tab_r = keyboard_check_pressed(global.key_tab_right) || gamepad_button_check_pressed(0, gp_shoulderr);
        
        if (tab_l) { opcao_aba = 0; pause_index = 0; tocar_sfx("snd_ui_move"); }
        if (tab_r) { opcao_aba = 1; pause_index = 0; tocar_sfx("snd_ui_move"); }
        
        var total_opcoes_aba = (opcao_aba == 0) ? 7 : 8; // Aba 0 agora tem 7 itens (com Volume)
        
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes_aba - 1; tocar_sfx("snd_ui_move"); }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes_aba) pause_index = 0; tocar_sfx("snd_ui_move"); }
        
        var key_toggle = key_confirm || key_left || key_right;
        
        if (opcao_aba == 0) {
            // Item 0: Volume Master
            if (pause_index == 0 && (key_left || key_right || key_confirm)) {
                if (key_left) global.vol_master = clamp(global.vol_master - 0.1, 0.0, 1.0);
                if (key_right || key_confirm) {
                    global.vol_master += 0.1;
                    if (global.vol_master > 1.0) global.vol_master = 0.0;
                }
                audio_master_gain(global.vol_master);
                salvar_configuracoes();
                tocar_sfx("snd_ui_move");
            }
            // Item 1 (Idioma), Item 2 (Tela Cheia), Item 4 (Tremor de Tela)
            else if (key_toggle && (pause_index == 1 || pause_index == 2 || pause_index == 4)) {
                switch (pause_index) {
                    case 1: global.idioma = (global.idioma == "PT") ? "EN" : "PT"; break;
                    case 2:
                        global.tela_cheia = !window_get_fullscreen();
                        aplicar_resolucao();
                        break;
                    case 4: global.tremer_tela = !global.tremer_tela; break;
                }
                salvar_configuracoes();
                tocar_sfx("snd_ui_confirm");
            }
            // Item 3: Resolução
            else if (pause_index == 3 && (key_left || key_right || key_confirm)) {
                if (!variable_global_exists("res_index")) global.res_index = 0;
                if (key_left) global.res_index--; else global.res_index++;
                if (global.res_index < 0) global.res_index = 2;
                if (global.res_index > 2) global.res_index = 0;
                aplicar_resolucao();
                salvar_configuracoes();
                tocar_sfx("snd_ui_confirm");
            }
            // Item 5: Brilho
            else if (pause_index == 5 && (key_left || key_right || key_confirm)) {
                if (key_left) global.brilho = clamp(global.brilho - 0.1, 0.1, 1.0);
                if (key_right || key_confirm) {
                    global.brilho += 0.1;
                    if (global.brilho > 1.0) global.brilho = 0.1;
                }
                salvar_configuracoes();
                tocar_sfx("snd_ui_move");
            }
            // Item 6: Voltar ao Menu de Pausa
            else if (key_confirm && pause_index == 6) {
                salvar_configuracoes();
                pause_state = 0;
                pause_index = 1;
                tocar_sfx("snd_ui_back");
            }
        }
        else if (opcao_aba == 1) {
            if (key_confirm) {
                if (pause_index >= 0 && pause_index <= 6) {
                    aguardando_tecla = true;
                    keyboard_clear(vk_anykey);
                    tocar_sfx("snd_ui_confirm");
                } else if (pause_index == 7) {
                    salvar_configuracoes();
                    pause_state = 0;
                    pause_index = 1;
                    tocar_sfx("snd_ui_back");
                }
            }
        }
    }
}