if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

duracao--;
if (duracao <= 0) {
    instance_destroy();
    exit;
}

// A cada 30 frames (meio segundo), queima qualquer inimigo na área das chamas (largura de 48px)
if (duracao mod 30 == 0) {
    var _inimigo = collision_rectangle(x - 24, y - 16, x + 24, y + 4, obj_enemy, false, true);
    if (_inimigo == noone && object_exists(obj_vespa)) {
        _inimigo = collision_rectangle(x - 24, y - 16, x + 24, y + 4, obj_vespa, false, true);
    }
    if (_inimigo == noone && object_exists(obj_boss_centopeia)) {
        _inimigo = collision_rectangle(x - 24, y - 16, x + 24, y + 4, obj_boss_centopeia, false, true);
    }
    
    if (_inimigo != noone) {
        with (_inimigo) {
            var pode_queimar = true;
            if (object_index == obj_boss_centopeia) {
                if (state == centopeia_state.subterranea || state == centopeia_state.emergindo) {
                    pode_queimar = false;
                }
            }
            if (pode_queimar) {
                hp -= other.dano_tick;
                piscar = 6;
                if (variable_instance_exists(id, "queimando_timer")) {
                    queimando_timer = 120;
                }
            }
        }
    }
}