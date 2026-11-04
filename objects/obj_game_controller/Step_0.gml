// --- SISTEMA DE PAUSA ---
var key_pause = keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start);

if (key_pause) {
    if (!is_paused) {
        is_paused = true;
        pause_index = 0;
        instance_deactivate_all(true); // Desativa todos os objetos exceto este!
    } else {
        is_paused = false;
        instance_activate_all(); // Volta a ligar tudo
    }
}

// Navegação do Menu de Pausa
if (is_paused) {
    var key_up = keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu);
    var key_down = keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd);
    var key_confirm = keyboard_check_pressed(vk_enter) || gamepad_button_check_pressed(0, gp_face1);
    
    if (key_up) { pause_index--; if (pause_index < 0) pause_index = array_length(pause_opcoes) - 1; }
    if (key_down) { pause_index++; if (pause_index >= array_length(pause_opcoes)) pause_index = 0; }
    
    if (key_confirm) {
        if (pause_index == 0) {
            // Continua a jogar
            is_paused = false;
            instance_activate_all();
        } else if (pause_index == 1) {
            // Volta para a capa do jogo
            is_paused = false;
            instance_activate_all();
            room_goto(rm_menu); 
        }
    }
}
// Alternar entre Tela Cheia e Modo Janela
if (keyboard_check_pressed(vk_f11)) {
    var tela_cheia = window_get_fullscreen();
    window_set_fullscreen(!tela_cheia);
}