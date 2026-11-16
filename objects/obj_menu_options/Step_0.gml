var key_up    = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
var key_down  = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
var key_left  = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || gamepad_button_check_pressed(0, gp_padl);
var key_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || gamepad_button_check_pressed(0, gp_padr);
var key_enter = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
var key_back  = keyboard_check_pressed(vk_escape)|| gamepad_button_check_pressed(0, gp_face2);

// Navegação para cima e para baixo
if (key_up) {
    menu_index--;
    if (menu_index < 0) menu_index = array_length(opcoes) - 1;
}
if (key_down) {
    menu_index++;
    if (menu_index >= array_length(opcoes)) menu_index = 0;
}

var opcao_atual = opcoes[menu_index];

// Interação com a opção selecionada
switch (opcao_atual) {
    case "volume_master":
        if (key_right && global.vol_master < 1.0) global.vol_master += 0.1;
        if (key_left && global.vol_master > 0.0) global.vol_master -= 0.1;
        global.vol_master = clamp(global.vol_master, 0, 1);
        audio_master_gain(global.vol_master); 
        break;
        
    case "tela_cheia":
        if (key_enter || key_left || key_right) {
            global.tela_cheia = !global.tela_cheia;
            window_set_fullscreen(global.tela_cheia);
        }
        break;
        
    case "tremer_tela":
        if (key_enter || key_left || key_right) {
            global.tremer_tela = !global.tremer_tela;
        }
        break;
        
    case "idioma":
        if (key_enter || key_left || key_right) {
            global.idioma = (global.idioma == "PT") ? "EN" : "PT";
        }
        break;
        
    case "voltar":
        if (key_enter || key_back) {
            // Salva as alterações no arquivo INI
            ini_open("config.ini");
            ini_write_real("Audio", "Master", global.vol_master);
            ini_write_real("Video", "Fullscreen", global.tela_cheia);
            ini_write_real("Video", "TremerTela", global.tremer_tela);
            ini_write_string("Geral", "Idioma", global.idioma);
            ini_close();
            
            // Volta para o menu principal
            room_goto(rm_main_menu); 
        }
        break;
}

// Atalho com ESC para voltar direto
if (key_back && opcao_atual != "voltar") {
    room_goto(rm_main_menu);
}