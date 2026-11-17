if (place_meeting(x, y, obj_player)) {
    var _interagir = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_face4);
    
    if (_interagir) {
        if (instance_exists(obj_player)) {
            obj_player.hp = 100;
        }
        salvar_jogo();
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.sala_montada = -1;
        }
        if (room == rm_forest_1) {
            room_goto(rm_forest_2);
        } else if (room == rm_forest_2) {
            room_goto(rm_forest_3);
        }
    }
}