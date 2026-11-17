sprite_index = (asset_get_index("spr_vespa_box") != -1) ? asset_get_index("spr_vespa_box") : spr_enemy_box;
if (!variable_instance_exists(id, "spawn_alpha")) spawn_alpha = 1.0;
if (!variable_instance_exists(id, "spawn_scale")) spawn_scale = 1.0;
if (spawn_alpha < 1.0) {
    spawn_alpha = min(1.0, spawn_alpha + 0.03);
    spawn_scale = lerp(spawn_scale, 1.0, 0.12);
    image_alpha = spawn_alpha;
    image_xscale = spawn_scale;
    image_yscale = spawn_scale;
    exit;
}
image_alpha = 1.0;

if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

switch (state) {
    case vespa_state.patrulha:
        vspd = sin(current_time / 200) * 1.5;
        hspd = cos(current_time / 300) * 1.0;
        
        if (instance_exists(obj_player)) {
            if (point_distance(x, y, obj_player.x, obj_player.y) <= vision_range) {
                state = vespa_state.perseguicao;
            }
        }
        break;
        
    case vespa_state.perseguicao:
        if (instance_exists(obj_player)) {
            var dir = point_direction(x, y, obj_player.x, obj_player.y - 35);
            hspd = lengthdir_x(vel_voo, dir);
            vspd = lengthdir_y(vel_voo, dir);
            
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist < 110) {
                alvo_x = obj_player.x;
                alvo_y = obj_player.y;
                state_timer = 25;
                tocar_sfx("snd_wasp_buzz", 0.95, 1.1);
                state = vespa_state.preparando;
            } else if (dist > vision_range * 1.5) {
                state = vespa_state.patrulha;
            }
        }
        break;
        
    case vespa_state.preparando:
        hspd = irandom_range(-1, 1);
        vspd = -0.5;
        
        if (instance_exists(obj_player)) {
            alvo_x = obj_player.x;
            alvo_y = obj_player.y;
            if (obj_player.x != x) image_xscale = sign(obj_player.x - x);
        }
        
        state_timer--;
        if (state_timer <= 0) {
            var dir_rasante = point_direction(x, y, alvo_x, alvo_y);
            hspd = lengthdir_x(vel_voo * 3.8, dir_rasante);
            vspd = lengthdir_y(vel_voo * 3.8, dir_rasante);
            state_timer = 25;
            tocar_sfx("snd_wasp_sting", 0.95, 1.1);
            state = vespa_state.rasante;
        }
        break;
        
    case vespa_state.rasante:
        state_timer--;
        if (place_meeting(x + hspd, y + vspd, obj_colisor) || state_timer <= 0) {
            hspd = 0;
            vspd = 0;
            state_timer = 35;
            state = vespa_state.recuperando;
        }
        break;
        
    case vespa_state.recuperando:
        hspd = lerp(hspd, 0, 0.2);
        vspd = sin(current_time / 150) * 0.8;
        state_timer--;
        if (state_timer <= 0) {
            state = vespa_state.perseguicao;
        }
        break;
}

if (!place_meeting(x + hspd, y, obj_colisor)) x += hspd;
if (!place_meeting(x, y + vspd, obj_colisor)) y += vspd;

if (hspd != 0 && state != vespa_state.preparando) {
    image_xscale = sign(hspd);
}

if (hp <= 0) {
    tocar_sfx("snd_wasp_buzz", 0.7, 0.85);
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 5;
        obj_game_controller.shake_magnitude = 3;
    }
    
    if (instance_exists(obj_player)) {
        obj_player.arma_xp += 5;
        if (obj_player.arma_xp >= obj_player.arma_xp_max) {
            if (obj_player.arma_nivel == 1) {
                obj_player.arma_nivel = 2;
                obj_player.arma_xp = 0;
                obj_player.arma_xp_max = 20;
            } else if (obj_player.arma_nivel == 2) {
                obj_player.arma_nivel = 3;
                obj_player.arma_xp = obj_player.arma_xp_max;
            }
        }
    }
    
    instance_create_layer(x, y, layer, obj_scrap);
    
    if (irandom(99) < 60 && object_exists(obj_item_drop)) {
        var _drop = instance_create_layer(x, y, layer, obj_item_drop);
        _drop.tipo_item = 2;
    }
    
    instance_destroy();
}