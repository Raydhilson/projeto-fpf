if (salvo_timer > 0) salvo_timer--;

if (instance_exists(obj_player)) {
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    var _interagir = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);
    
    if (_dist <= 40 && _interagir) {
        obj_player.hp = 100; // Recupera a vida
        salvar_jogo(1);      // Salva no save_1.ini
        salvo_timer = 120;   // Mostra mensagem por 2 segundos
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.shake_magnitude = 2;
        }
    }
}