if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    aplicar_resolucao();
    salvar_configuracoes();
}

// ==========================================
// 1. MODO DE REBIND (CAPTURANDO TECLA NOVA)
// ==========================================
if (menu_state == 1 && opcao_aba == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (menu_index) {
                case 0: global.key_jump   = nova_tecla; break;
                case 1: global.key_attack = nova_tecla; break;
                case 2: global.key_roll   = nova_tecla; break;
                case 3: global.key_heal   = nova_tecla; break;
                case 4: global.key_throw  = nova_tecla; break;
                case 5: global.key_left   = nova_tecla; break;
                case 6: global.key_right  = nova_tecla; break;
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
// 2. LEITURA DE NAVEGAÇÃO
// ==========================================
var key_up     = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
var key_down   = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
var key_left   = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || gamepad_button_check_pressed(0, gp_padl);
var key_right  = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || gamepad_button_check_pressed(0, gp_padr);
var key_enter  = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
var key_back   = keyboard_check_pressed(vk_escape)|| gamepad_button_check_pressed(0, gp_face2);
var key_delete = keyboard_check_pressed(vk_delete)|| keyboard_check_pressed(ord("X")) || gamepad_button_check_pressed(0, gp_face3);

// --- ESTADO 0: MENU PRINCIPAL ---
if (menu_state == 0) {
    has_save = (save_existe(1) || save_existe(2) || save_existe(3));
    
    if (key_up) {
        menu_index--;
        if (menu_index < 0) menu_index = array_length(options) - 1;
        if (menu_index == 1 && !has_save) menu_index = 0;
        tocar_sfx("snd_ui_move", 0.95, 1.05);
    }
    
    if (key_down) {
        menu_index++;
        if (menu_index >= array_length(options)) menu_index = 0;
        if (menu_index == 1 && !has_save) menu_index = 2;
        tocar_sfx("snd_ui_move", 0.95, 1.05);
    }
    
    if (key_enter) {
        tocar_sfx("snd_ui_confirm");
        switch (options[menu_index]) {
            case "new_game":
                modo_slot  = "new";
                slots_info = [obter_info_slot(1), obter_info_slot(2), obter_info_slot(3)];
                slot_index = 0;
                menu_state = 2;
                break;
            case "continue_game":
                if (has_save) {
                    modo_slot  = "load";
                    slots_info = [obter_info_slot(1), obter_info_slot(2), obter_info_slot(3)];
                    slot_index = 0;
                    menu_state = 2;
                }
                break;
            case "options":
                menu_state = 1;
                opcao_aba  = 0;
                menu_index = 0;
                break;
            case "quit":
                game_end();
                break;
        }
    }
}
// --- ESTADO 1: SUB-MENU DE OPÇÕES COM ABAS ---
else if (menu_state == 1) {
    var tab_l = keyboard_check_pressed(global.key_tab_left)  || gamepad_button_check_pressed(0, gp_shoulderl);
    var tab_r = keyboard_check_pressed(global.key_tab_right) || gamepad_button_check_pressed(0, gp_shoulderr);
    
    if (tab_l) { opcao_aba = 0; menu_index = 0; tocar_sfx("snd_ui_move"); }
    if (tab_r) { opcao_aba = 1; menu_index = 0; tocar_sfx("snd_ui_move"); }
    
    var total_opcoes_aba = (opcao_aba == 0) ? 6 : 8;
    
    if (key_up)   { menu_index--; if (menu_index < 0) menu_index = total_opcoes_aba - 1; tocar_sfx("snd_ui_move"); }
    if (key_down) { menu_index++; if (menu_index >= total_opcoes_aba) menu_index = 0; tocar_sfx("snd_ui_move"); }
    
    if (key_back) {
        salvar_configuracoes();
        menu_state = 0;
        menu_index = 2;
        keyboard_clear(vk_escape);
        exit;
    }
    
    var key_toggle = key_enter || key_left || key_right;
    
    if (opcao_aba == 0) {
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
            tocar_sfx("snd_ui_confirm");
        }
        else if (menu_index == 2 && (key_left || key_right || key_enter)) {
            if (!variable_global_exists("res_index")) global.res_index = 0;
            if (key_left) global.res_index--; else global.res_index++;
            if (global.res_index < 0) global.res_index = 2;
            if (global.res_index > 2) global.res_index = 0;
            aplicar_resolucao();
            salvar_configuracoes();
            tocar_sfx("snd_ui_confirm");
        }
        else if (menu_index == 4 && (key_left || key_right || key_enter)) {
            if (key_left) global.brilho = clamp(global.brilho - 0.1, 0.1, 1.0);
            if (key_right || key_enter) {
                global.brilho += 0.1;
                if (global.brilho > 1.0) global.brilho = 0.1;
            }
            salvar_configuracoes();
            tocar_sfx("snd_ui_move");
        }
        else if (key_enter && menu_index == 5) {
            salvar_configuracoes();
            menu_state = 0;
            menu_index = 2;
            tocar_sfx("snd_ui_confirm");
        }
    }
    else if (opcao_aba == 1) {
        if (key_enter) {
            if (menu_index >= 0 && menu_index <= 6) {
                aguardando_tecla = true;
                keyboard_clear(vk_anykey);
            } else if (menu_index == 7) {
                salvar_configuracoes();
                menu_state = 0;
                menu_index = 2;
            }
        }
    }
}
// --- ESTADO 2: TELA DE SELEÇÃO DE 3 SLOTS DE SAVE ---
else if (menu_state == 2) {
    if (key_up) {
        slot_index--;
        if (slot_index < 0) slot_index = 3;
        tocar_sfx("snd_ui_move");
    }
    if (key_down) {
        slot_index++;
        if (slot_index > 3) slot_index = 0;
        tocar_sfx("snd_ui_move");
    }
    
    if (key_back) {
        menu_state = 0;
        has_save   = (save_existe(1) || save_existe(2) || save_existe(3));
        menu_index = has_save ? 1 : 0;
        keyboard_clear(vk_escape);
        exit;
    }
    
    // Apagar Slot selecionado com [DEL] ou [X]
    if (key_delete && slot_index >= 0 && slot_index <= 2) {
        var _num_s = slot_index + 1;
        if (save_existe(_num_s)) {
            apagar_save(_num_s);
            slots_info = [obter_info_slot(1), obter_info_slot(2), obter_info_slot(3)];
            has_save   = (save_existe(1) || save_existe(2) || save_existe(3));
            tocar_sfx("snd_ui_confirm", 0.7, 0.8);
        }
    }
    
    if (key_enter) {
        if (slot_index == 3) {
            menu_state = 0;
            has_save   = (save_existe(1) || save_existe(2) || save_existe(3));
            menu_index = has_save ? 1 : 0;
        } else {
            var _slot_escolhido = slot_index + 1;
            if (modo_slot == "new") {
                tocar_sfx("snd_ui_confirm");
                novo_jogo(_slot_escolhido);
            } else if (modo_slot == "load") {
                if (slots_info[slot_index].existe) {
                    tocar_sfx("snd_ui_confirm");
                    carregar_jogo(_slot_escolhido);
                } else {
                    // Se o jogador clicou num slot vazio no modo Continuar, inicia um Novo Jogo nele
                    tocar_sfx("snd_ui_confirm");
                    novo_jogo(_slot_escolhido);
                }
            }
        }
    }
}