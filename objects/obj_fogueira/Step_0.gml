if (place_meeting(x, y, obj_player)) {
    // [E] = Kit de Suprimentos e Reparo do Portão (Custa 3 Sucatas)
    if (keyboard_check_pressed(ord("E")) || gamepad_button_check_pressed(0, gp_face4)) {
        if (global.scrap >= 3) {
            global.scrap -= 3;
            obj_player.hp = min(obj_player.hp_max, obj_player.hp + 35);
            obj_player.curativo_count += 1;
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.portao_hp = min(obj_game_controller.portao_hp_max, obj_game_controller.portao_hp + 50);
            }
            tocar_sfx("snd_craft_success", 1.0, 1.15);
        } else {
            tocar_sfx("snd_craft_fail", 0.95, 1.05);
        }
    }
    
    // [R] = Afiar Lança no Mercador (+4 Dano Base Permanente | Custa 5 Sucatas)
    if (keyboard_check_pressed(ord("R")) || gamepad_button_check_pressed(0, gp_face2)) {
        if (global.scrap >= 5) {
            global.scrap -= 5;
            global.ataque_base += 4;
            tocar_sfx("snd_craft_hammer", 1.0, 1.15);
        } else {
            tocar_sfx("snd_craft_fail", 0.95, 1.05);
        }
    }
}