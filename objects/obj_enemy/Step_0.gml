sprite_index = spr_enemy_box;
mask_index   = spr_enemy_box;

var _escala_x = 44 / max(1, sprite_get_width(spr_enemy_box));
var _escala_y = 40 / max(1, sprite_get_height(spr_enemy_box));

if (!variable_instance_exists(id, "hp_max"))      hp_max = hp;
if (!variable_instance_exists(id, "spawn_alpha")) spawn_alpha = 1.0;
if (!variable_instance_exists(id, "spawn_scale")) spawn_scale = 1.0;
if (!variable_instance_exists(id, "anim_walk"))   anim_walk = random(10);

if (spawn_alpha < 1.0) {
    spawn_alpha = min(1.0, spawn_alpha + 0.04);
    spawn_scale = lerp(spawn_scale, 1.0, 0.15);
    image_alpha = spawn_alpha;
    image_xscale = sign(facing == 0 ? 1 : facing) * _escala_x * spawn_scale;
    image_yscale = _escala_y * spawn_scale;
    hspd = 0;
    exit;
}
image_alpha = 1.0;

if (instance_exists(obj_game_controller) && (obj_game_controller.hitstop_timer > 0 || obj_game_controller.escolhendo_carta || obj_game_controller.is_dead)) {
    exit;
}

vspd += grv;
if (piscar > 0) piscar--;
if (attack_cooldown > 0) attack_cooldown--;

if (piscar == 3 && instance_exists(obj_player)) {
    hspd = sign(x - obj_player.x) * 4.5;
    vspd = -2.0;
}

if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

var on_ground = place_meeting(x, y + 1, obj_colisor);
var _portao_x = instance_exists(obj_game_controller) ? obj_game_controller.portao_x : 120;

// IA SIMPLES DO BESOURO COMUM: Marcha e dá Charge (Investida)
if (instance_exists(obj_player)) {
    var dist_player = point_distance(x, y, obj_player.x, obj_player.y);
    var focar_player = (dist_player <= 160);
    var alvo_x = focar_player ? obj_player.x : _portao_x;
    var dir_alvo = sign(alvo_x - x);
    if (dir_alvo == 0) dir_alvo = -1;
    
    switch (state) {
        // 1. Anda até o alvo
        case enemy_state.chase:
            anim_walk += 0.22;
            image_blend = (queimando_timer > 0) ? c_orange : make_color_rgb(70, 130, 230);
            if (piscar <= 0) {
                facing = dir_alvo;
                hspd = lerp(hspd, chase_spd * facing, 0.12);
            }
            
            var _perto_portao = (abs(x - _portao_x) <= 42);
            if (((focar_player && dist_player <= 80) || _perto_portao) && on_ground && attack_cooldown <= 0) {
                state = enemy_state.prep_charge;
                hspd = 0;
                state_timer = 35;
            }
            break;
            
        // 2. Prepara a investida (Fica amarelo)
        case enemy_state.prep_charge:
            hspd = lerp(hspd, 0, 0.3);
            image_blend = c_yellow;
            facing = dir_alvo;
            state_timer--;
            if (state_timer <= 0) {
                state = enemy_state.charge;
                state_timer = 18;
                tocar_sfx("snd_beetle_charge", 0.95, 1.05);
            }
            break;
            
        // 3. Executa o Charge (Investida física)
        case enemy_state.charge:
            image_blend = make_color_rgb(235, 65, 65);
            state_timer--;
            hspd = facing * charge_spd;
            
            if (abs(x - _portao_x) <= 38 && instance_exists(obj_game_controller)) {
                obj_game_controller.portao_hp -= 15;
                obj_game_controller.portao_piscar = 20;
                obj_game_controller.shake_magnitude = 5;
                if (variable_instance_exists(obj_game_controller, "portao_espinhos") && obj_game_controller.portao_espinhos > 0) {
                    hp -= obj_game_controller.portao_espinhos;
                    piscar = 4;
                }
                tocar_sfx("snd_craft_hammer", 0.7, 0.85);
                hspd = 4;
                state = enemy_state.cooldown;
                state_timer = 50;
                attack_cooldown = 90;
                break;
            }
            
            if (place_meeting(x + facing, y, obj_colisor) || state_timer <= 0) {
                hspd = 0;
                state = enemy_state.cooldown;
                state_timer = 40;
                attack_cooldown = 90;
            }
            break;
            
        // 4. Descansa pós-charge
        case enemy_state.cooldown:
            hspd = lerp(hspd, 0, 0.2);
            image_blend = c_ltgray;
            state_timer--;
            if (state_timer <= 0) {
                state = enemy_state.chase;
            }
            break;
    }
}

var _wobble = (state == enemy_state.chase) ? sin(anim_walk) * 0.08 : 0;
var _prep_squash = (state == enemy_state.prep_charge) ? -0.22 : 0;
if (piscar > 0) _prep_squash = 0.25;

image_xscale = facing * _escala_x * (1.0 - _prep_squash + _wobble);
image_yscale = _escala_y * (1.0 + _prep_squash - _wobble);

if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) x += sign(hspd);
    hspd = 0;
}
x += hspd;

if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) y += sign(vspd);
    vspd = 0;
}
y += vspd;

// MORTE: Dropa apenas Sucata (Moeda do Mercador) e dá Score!
if (hp <= 0) {
    tocar_sfx("snd_beetle_carapace", 0.9, 1.1);
    global.score_atual += 100;
    
    instance_create_depth(x, y - 6, 0, obj_scrap);
    
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 4;
        obj_game_controller.shake_magnitude = 4;
    }
    instance_destroy();
}