if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

vspd += grv;
vida_timer--;

// 1. Acertou o chão ou parede
if (collision_circle(x + hspd, y + vspd, 5, obj_colisor, false, true) != noone || vida_timer <= 0) {
    instance_destroy();
    exit;
}

// 2. Acertou o Player (Garante o acerto mesmo se o ácido não tiver sprite atribuída!)
if (instance_exists(obj_player)) {
    var hit_p = collision_circle(x, y, 6, obj_player, false, true);
    if (hit_p != noone && !hit_p.is_invulnerable && hit_p.state != player_state.roll) {
        hit_p.hp -= dano;
        hit_p.is_invulnerable = true;
        hit_p.iframe_timer = 45;
        
        var dir_acido = (hspd != 0) ? sign(hspd) : -hit_p.facing;
        hit_p.hspd = dir_acido * 4;
        hit_p.vspd = -3;
        hit_p.state = player_state.air;
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.hitstop_timer = 4;
            obj_game_controller.shake_magnitude = 3;
        }
        instance_destroy();
        exit;
    }
}

x += hspd;
y += vspd;