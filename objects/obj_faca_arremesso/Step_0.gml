if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

vspd += grv;

// 1. Bateu na parede
if (collision_circle(x + hspd, y + vspd, 4, obj_colisor, false, true) != noone) {
    instance_destroy();
    exit;
}

// 2. Acertou Inimigo
var hit_enemy = collision_circle(x + hspd, y + vspd, 8, obj_enemy, false, true);
if (hit_enemy == noone && object_exists(obj_vespa)) {
    hit_enemy = collision_circle(x + hspd, y + vspd, 8, obj_vespa, false, true);
}
if (hit_enemy == noone && object_exists(obj_boss_centopeia)) {
    hit_enemy = collision_circle(x + hspd, y + vspd, 8, obj_boss_centopeia, false, true);
}

if (hit_enemy != noone) {
    with (hit_enemy) {
        var pode_acertar = true;
        if (object_index == obj_boss_centopeia) {
            if (state == centopeia_state.subterranea || state == centopeia_state.emergindo) {
                pode_acertar = false;
            }
        }
        
        if (pode_acertar) {
            hp -= other.dano;
            piscar = 10;
            if (object_index != obj_boss_centopeia) {
                hspd = sign(other.hspd) * 7;
                vspd = -3;
            }
        }
    }
    
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 5;
        obj_game_controller.shake_magnitude = 3;
    }
    instance_destroy();
    exit;
}

x += hspd;
y += vspd;