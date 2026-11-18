enum enemy_state {
    chase,
    prep_charge,
    charge,
    cooldown
}

state = enemy_state.chase;
state_timer = 0;

hp_max = 3;
hp = hp_max;
hspd = 0;
vspd = 0;
grv = 0.4;
chase_spd = 2.0;
charge_spd = 6.2;
facing = -1;

piscar = 0;
attack_cooldown = 0;
queimando_timer = 0;

spawn_alpha = 1.0;
spawn_scale = 1.0;
anim_walk = random(10);