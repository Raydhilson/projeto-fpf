// Respeita o Hitstop global
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

vspd += grv;

x += hspd;
y += vspd;

// Destrói o ácido ao bater no chão ou na parede
if (place_meeting(x, y, obj_colisor)) {
    instance_destroy();
}