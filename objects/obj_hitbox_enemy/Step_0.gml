duracao--;
if (duracao <= 0) {
    instance_destroy();
    exit;
}

// Verifica se encostou no player
var _player = instance_place(x, y, obj_player);
if (_player != noone && !_player.is_invulnerable && _player.state != player_state.roll) {
    _player.hp -= dano;
    _player.is_invulnerable = true;
    _player.iframe_timer = 65;
    _player.hspd = sign(_player.x - x) * 6;
    _player.vspd = -4;
    _player.state = player_state.air;

    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 5;
        obj_game_controller.shake_magnitude = 4;
    }

    instance_destroy();
}