// Alinha o Mercador exatamente na superfície do chão (onde o Player pisa!)
if (instance_exists(obj_colisor)) {
    while (place_meeting(x, y, obj_colisor) && y > 60) {
        y -= 1;
    }
    while (!place_meeting(x, y + 1, obj_colisor) && y < room_height - 32) {
        y += 1;
    }
}

if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 90) {
    // [E] ou [X/Quadrado no Controle]: Comprar CURA (+40 HP + 1 Curativo + Reparo da Barricada) = $2
    var _buy_cura = keyboard_check_pressed(ord("E")) || gamepad_button_check_pressed(0, gp_face4);
    if (_buy_cura) {
        if (global.scrap >= 2) {
            global.scrap -= 2;
            obj_player.hp = min(obj_player.hp_max, obj_player.hp + 40);
            obj_player.curativo_count += 1;
            
            // Repara a barricada se ela existir na sala
            if (instance_exists(obj_barricada)) {
                obj_barricada.hp = min(obj_barricada.hp_max, obj_barricada.hp + 40);
            }
            tocar_sfx("snd_craft_success", 1.0, 1.15);
        } else {
            tocar_sfx("snd_craft_fail", 0.95, 1.05);
        }
    }
    
    // [R] ou [B/Bolinha no Controle]: Comprar EXPLOSIVOS (+2 Molotovs + 3 Facas) = $3
    var _buy_explosivo = keyboard_check_pressed(ord("R")) || gamepad_button_check_pressed(0, gp_face2);
    if (_buy_explosivo) {
        if (global.scrap >= 3) {
            global.scrap -= 3;
            obj_player.molotov_count += 2;
            obj_player.faca_count += 3;
            tocar_sfx("snd_craft_hammer", 1.0, 1.15);
        } else {
            tocar_sfx("snd_craft_fail", 0.95, 1.05);
        }
    }
}