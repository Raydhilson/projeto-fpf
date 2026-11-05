var key_up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
var key_down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
var key_enter = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);

// Navegação do cursor
if (key_up) {
    menu_index--;
    if (menu_index < 0) menu_index = array_length(options) - 1;
    
    // Pula o "continue_game" se não houver save
    if (menu_index == 1 && !has_save) menu_index = 0;
}

if (key_down) {
    menu_index++;
    if (menu_index >= array_length(options)) menu_index = 0;
    
    // Pula o "continue_game" se não houver save
    if (menu_index == 1 && !has_save) menu_index = 2;
}

// Ações dos botões
if (key_enter) {
    switch (options[menu_index]) {
        case "new_game":
            novo_jogo(1); // Chama a função do seu script
            break;
            
        case "continue_game":
            if (has_save) {
                carregar_jogo(1);
            }
            break;
            
        case "options":
            room_goto(rm_options); // Lembre-se de renomear a sala de opções para rm_options
            break;
            
        case "quit":
            game_end();
            break;
    }
}