var key_up = keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu);
var key_down = keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd);
var key_confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);

if (key_up) { menu_index--; if (menu_index < 0) menu_index = array_length(opcoes) - 1; }
if (key_down) { menu_index++; if (menu_index >= array_length(opcoes)) menu_index = 0; }

if (key_confirm) {
    if (menu_index == 0) {
        room_goto(Room1); // Vai para a sala do teu jogo (confirma se o nome é Room1)
    } else if (menu_index == 1) {
        game_end(); // Fecha o jogo
    }
}