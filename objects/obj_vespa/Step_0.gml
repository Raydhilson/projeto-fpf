sprite_index = spr_vespa_box;
mask_index   = spr_vespa_box;

// Deixa a Vespa menorzinha e ágil (32x32 pixels)
var _escala_v = 32 / max(1, sprite_get_width(spr_vespa_box));

if (!variable_instance_exists(id, "hp"))            hp = 3;
if (!variable_instance_exists(id, "hp_max"))        hp_max = hp;
if (!variable_instance_exists(id, "spawn_alpha"))   spawn_alpha = 1.0;
if (!variable_instance_exists(id, "spawn_scale"))   spawn_scale = 1.0;
if (!variable_instance_exists(id, "piscar"))        piscar = 0;
if (!variable_instance_exists(id, "timer_voo"))     timer_voo = random(10);
if (!variable_instance_exists(id, "estado_vespa"))  estado_vespa = 0;
if (!variable_instance_exists(id, "timer_ataque"))  timer_ataque = 80;
if (!variable_instance_exists(id, "dir_x"))         dir_x = 0;
if (!variable_instance_exists(id, "dir_y"))         dir_y = 0;

if (spawn_alpha < 1.0) {
    spawn_alpha = min(1.0, spawn_alpha + 0.04);
    spawn_scale = lerp(spawn_scale, 1.0, 0.15);
    image_alpha = spawn_alpha;
    image_xscale = _escala_v * spawn_scale;
    image_yscale = _escala_v * spawn_scale;
    exit;
}
image_alpha  = 1.0;
image_xscale = _escala_v * (1.0 + sin(timer_voo * 3) * 0.08);
image_yscale = _escala_v * (1.0 - sin(timer_voo * 3) * 0.08);

if (instance_exists(obj_game_controller) && (obj_game_controller.hitstop_timer > 0 || obj_game_controller.escolhendo_carta || obj_game_controller.is_dead)) {
    exit;
}

if (piscar > 0) piscar--;
timer_voo += 0.10;

var _portao_x = instance_exists(obj_game_controller) ? obj_game_controller.portao_x : 120;

if (instance_exists(obj_player)) {
    var _dist_p = point_distance(x, y, obj_player.x, obj_player.y);
    var _focar_p = (_dist_p < 200);
    var _alvo_x = _focar_p ? obj_player.x : _portao_x;
    var _alvo_y = obj_player.y - 16;
    
    // Empurrão quando leva golpe da lança
    if (piscar == 3) {
        x += sign(x - obj_player.x) * 14;
        y -= 8;
    }
    
    if (estado_vespa == 0) {
        image_blend = make_color_rgb(220, 160, 40);
        x = lerp(x, _alvo_x, 0.025);
        y = lerp(y, (_alvo_y - 75) + sin(timer_voo) * 14, 0.05);
        
        timer_ataque--;
        if (timer_ataque <= 0 && (_dist_p < 220 || abs(x - _portao_x) < 120)) {
            estado_vespa = 1;
            timer_ataque = 35;
            tocar_sfx("snd_wasp_buzz", 1.1, 1.2);
        }
    }
    else if (estado_vespa == 1) {
        image_blend = c_yellow;
        y -= 0.8;
        timer_ataque--;
        if (timer_ataque <= 0) {
            estado_vespa = 2;
            timer_ataque = 20;
            var _ang = point_direction(x, y, _alvo_x, _alvo_y);
            dir_x = lengthdir_x(7.0, _ang);
            dir_y = lengthdir_y(7.0, _ang);
            tocar_sfx("snd_wasp_sting", 0.95, 1.05);
        }
    }
    else if (estado_vespa == 2) {
        image_blend = c_red;
        if (!place_meeting(x + dir_x, y, obj_colisor)) x += dir_x;
        if (!place_meeting(x, y + dir_y, obj_colisor)) y += dir_y;
        
        if (abs(x - _portao_x) <= 35 && instance_exists(obj_game_controller)) {
            obj_game_controller.portao_hp -= 10;
            obj_game_controller.portao_piscar = 15;
            estado_vespa = 3;
            timer_ataque = 50;
        }
        
        timer_ataque--;
        if (timer_ataque <= 0 || place_meeting(x, y + 2, obj_colisor)) {
            estado_vespa = 3;
            timer_ataque = 45;
        }
    }
    else if (estado_vespa == 3) {
        image_blend = c_ltgray;
        y = lerp(y, _alvo_y - 80, 0.06);
        timer_ataque--;
        if (timer_ataque <= 0) {
            estado_vespa = 0;
            timer_ataque = 90;
        }
    }
}

if (hp <= 0) {
    tocar_sfx("snd_beetle_carapace", 1.1, 1.3);
    global.score_atual += 150;
    
    instance_create_depth(x, y, 0, obj_scrap);
    if (object_exists(obj_item_drop)) {
        var _ferrao = instance_create_depth(x, y - 6, 0, obj_item_drop);
        _ferrao.tipo_item = 2;
    }
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 4;
        obj_game_controller.shake_magnitude = 4;
    }
    instance_destroy();
}