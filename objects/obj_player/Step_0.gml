if (!variable_instance_exists(id, "escala_base"))       escala_base = 1.15;
if (!variable_instance_exists(id, "spin_cooldown"))     spin_cooldown = 0;
if (!variable_instance_exists(id, "spin_cooldown_max")) spin_cooldown_max = 300;
if (!variable_instance_exists(id, "spin_dano_bonus"))   spin_dano_bonus = 0;
if (!variable_instance_exists(id, "vampirismo_hp"))     vampirismo_hp = 0;

// =====================================================================
// 0. SISTEMA DE HITSTOP E BLOQUEIO DE PAUSE / MORTE / CARTAS
// =====================================================================
if (instance_exists(obj_game_controller)) {
    if (obj_game_controller.is_paused || obj_game_controller.is_dead || obj_game_controller.escolhendo_carta) {
        image_speed = 0;
        exit;
    }
    if (obj_game_controller.hitstop_timer > 0) {
        image_speed = 0;
        exit;
    }
}
image_speed = 1;

// =====================================================================
// 1. LEITURA DE CONTROLES E DIREÇÃO
// =====================================================================
var move_dir = keyboard_check(global.key_right) - keyboard_check(global.key_left);

if (move_dir == 0) {
    var deadzone = 0.2;
    var axis_h = gamepad_axis_value(0, gp_axislh);
    if (abs(axis_h) > deadzone) { move_dir = sign(axis_h); }
}

if (move_dir != 0 && state != player_state.menu && state != player_state.craft && state != player_state.roll) { 
    if (state != player_state.attack || action_timer >= 18) {
        facing = move_dir; 
    }
}

var key_jump          = keyboard_check_pressed(global.key_jump)     || gamepad_button_check_pressed(0, gp_face1);
var key_jump_released = keyboard_check_released(global.key_jump)    || gamepad_button_check_released(0, gp_face1); 
var key_attack        = keyboard_check_pressed(global.key_attack)   || gamepad_button_check_pressed(0, gp_face3); 
var key_roll          = keyboard_check_pressed(global.key_roll)     || gamepad_button_check_pressed(0, gp_face2); 
var key_throw         = keyboard_check_pressed(global.key_throw)    || gamepad_button_check_pressed(0, gp_shoulderr);
var key_spin          = keyboard_check_pressed(global.key_spin)     || keyboard_check_pressed(ord("L")) || gamepad_button_check_pressed(0, gp_shoulderl);

var key_menu    = keyboard_check_pressed(global.key_menu) || gamepad_button_check_pressed(0, gp_start);
var key_heal    = keyboard_check_pressed(global.key_heal) || gamepad_button_check_pressed(0, gp_padl);
var key_up      = keyboard_check_pressed(global.key_up)   || keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
var key_down    = keyboard_check_pressed(global.key_down) || keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
var key_confirm = keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);

var key_tab_left  = keyboard_check_pressed(global.key_tab_left)  || gamepad_button_check_pressed(0, gp_shoulderl);
var key_tab_right = keyboard_check_pressed(global.key_tab_right) || gamepad_button_check_pressed(0, gp_shoulderr);

// =====================================================================
// 2. USO DE ITENS (CURATIVO), GOLPE GIRATÓRIO E BUFFS
// =====================================================================
if (state != player_state.menu && state != player_state.craft) {
    if (spin_cooldown > 0) spin_cooldown--;
    if (buff_fogo_timer > 0) buff_fogo_timer--;
    
    if (key_heal && curativo_count > 0 && hp < hp_max) {
        curativo_count--;
        hp = min(hp + 30, hp_max);
        tocar_sfx("snd_craft_success", 1.05, 1.15);
        tocar_sfx("snd_mouse_squeak", 1.0, 1.15);
    }
    
    // HABILIDADE ESPECIAL: GOLPE GIRATÓRIO 360° (TECLA L)
    if (key_spin && spin_cooldown <= 0 && state != player_state.roll) {
        spin_cooldown = spin_cooldown_max;
        state = player_state.attack;
        action_timer = 22;
        combo_count = 2;
        sprite_index = spr_player_attack2;
        image_index = 0;
        tocar_sfx("snd_spear_thrust", 0.75, 0.85);
        tocar_sfx("snd_souls_roll", 1.1, 1.25);
        
        scale_x = escala_base * 1.5;
        scale_y = escala_base * 0.75;
        
        // Cria Hitbox dupla (Frente e Costas) usando depth 0
        var _h1 = instance_create_depth(x + 28, y - 12, 0, obj_hitbox);
        _h1.image_xscale = 2.2;
        _h1.duracao = 8;
        _h1.dano = 3 + spin_dano_bonus;
        if (buff_fogo_timer > 0) _h1.aplica_fogo = true;
        
        var _h2 = instance_create_depth(x - 28, y - 12, 0, obj_hitbox);
        _h2.image_xscale = -2.2;
        _h2.duracao = 8;
        _h2.dano = 3 + spin_dano_bonus;
        if (buff_fogo_timer > 0) _h2.aplica_fogo = true;
        
        // Empurra todos os inimigos próximos para longe do Portão!
        with (obj_enemy) {
            if (point_distance(x, y, other.x, other.y) < 120) {
                hspd = 7;
                vspd = -3.5;
            }
        }
        if (instance_exists(obj_game_controller)) obj_game_controller.shake_magnitude = 5;
    }
}

var on_ground = place_meeting(x, y + 1, obj_colisor);
if (on_ground) { coyote_timer = coyote_time_max; } else { coyote_timer = max(0, coyote_timer - 1); }
if (key_jump)  { jump_buffer_timer = jump_buffer_max; } else { jump_buffer_timer = max(0, jump_buffer_timer - 1); }

// ==========================================
// GATILHO DIRETO DO MENU DO PLAYER (TECLA I)
// ==========================================
if (key_menu) {
    if (state != player_state.menu && state != player_state.craft) {
        tocar_sfx("snd_ui_confirm", 0.95, 1.05);
        state = player_state.menu;
        hspd = 0;
        vspd = 0;
        menu_index = 0;
        aba_atual = 1;
        
        instance_deactivate_all(true);
        instance_activate_object(obj_game_controller);
        instance_activate_object(obj_camera);
        instance_activate_object(obj_colisor);
    } else {
        tocar_sfx("snd_ui_back", 0.95, 1.05);
        state = player_state.idle;
        instance_activate_all();
    }
    keyboard_clear(global.key_menu);
}

// =====================================================================
// 3. MÁQUINA DE ESTADOS (FSM)
// =====================================================================
switch (state) {
    
    // --- PARADO ---
    case player_state.idle:
        hspd = lerp(hspd, 0, fric); 
        if (abs(hspd) < 0.1) hspd = 0;
        
        image_blend = c_white;
        sprite_index = spr_player_idle;
        
        if (move_dir != 0) state = player_state.run;
        if (!on_ground) state = player_state.air; 
        
        if (jump_buffer_timer > 0 && coyote_timer > 0) { 
            vspd = jump_spd; jump_buffer_timer = 0; coyote_timer = 0;
            scale_x = escala_base * 0.75; scale_y = escala_base * 1.35; 
            tocar_sfx("snd_jump", 0.95, 1.08);
            state = player_state.air; 
        }
        
        if (key_attack) {
            if (move_dir != 0) facing = move_dir;
            state = player_state.attack;
            action_timer = 24; 
            combo_count = 1;        
            sprite_index = spr_player_attack; 
            image_index = 0;        
            ataque_buffer = false; 
            hspd = facing * 3.0; 
            scale_x = escala_base * 1.25; scale_y = escala_base * 0.85;
        }
        
        if (key_throw) {
            if (faca_count > 0 && object_exists(obj_faca_arremesso)) {
                faca_count--;
                var faca = instance_create_depth(x + (facing * 12), y - 14, 0, obj_faca_arremesso);
                faca.hspd = facing * 11; faca.vspd = -1;
                tocar_sfx("snd_dash", 1.15, 1.3);
            } else if (molotov_count > 0 && object_exists(obj_molotov)) {
                molotov_count--;
                var molotov = instance_create_depth(x + (facing * 10), y - 15, 0, obj_molotov);
                molotov.hspd = facing * 6.5; molotov.vspd = -4.5;
                tocar_sfx("snd_dash", 0.85, 0.95);
            }
        }
        
        if (key_roll) {
            state = player_state.roll; 
            action_timer = 14; 
            is_invulnerable = true; 
            iframe_timer = max(iframe_timer, 14); 
            sprite_index = spr_player_roll; 
            image_index = 0;
            tocar_sfx("snd_souls_roll", 0.95, 1.08);
        }
        break;
        
    // --- CORRENDO ---
    case player_state.run:
        hspd = lerp(hspd, move_dir * walk_sp, accel); 
        image_blend = c_white;
        sprite_index = spr_player_walk;
        
        if (move_dir == 0) state = player_state.idle;
        if (!on_ground) state = player_state.air;
        
        if (jump_buffer_timer > 0 && coyote_timer > 0) { 
            vspd = jump_spd; jump_buffer_timer = 0; coyote_timer = 0;
            scale_x = escala_base * 0.75; scale_y = escala_base * 1.35; 
            tocar_sfx("snd_jump", 0.95, 1.08);
            state = player_state.air; 
        }
        
        if (key_attack) {
            if (move_dir != 0) facing = move_dir;
            state = player_state.attack;
            action_timer = 24; 
            combo_count = 1;        
            sprite_index = spr_player_attack; 
            image_index = 0;
            ataque_buffer = false;
            
            hspd = facing * 3.5;
            scale_x = escala_base * 1.25;
            scale_y = escala_base * 0.85;
        }

        if (key_throw) {
            if (faca_count > 0 && object_exists(obj_faca_arremesso)) {
                faca_count--;
                var faca = instance_create_depth(x + (facing * 12), y - 14, 0, obj_faca_arremesso);
                faca.hspd = facing * 12; faca.vspd = -1;
                tocar_sfx("snd_dash", 1.15, 1.3);
            } else if (molotov_count > 0 && object_exists(obj_molotov)) {
                molotov_count--;
                var molotov = instance_create_depth(x + (facing * 10), y - 15, 0, obj_molotov);
                molotov.hspd = facing * 8; molotov.vspd = -4;
                tocar_sfx("snd_dash", 0.85, 0.95);
            }
        }
        
        if (key_roll) {
            state = player_state.roll; 
            action_timer = 14; 
            is_invulnerable = true; 
            iframe_timer = max(iframe_timer, 14);
            sprite_index = spr_player_roll; 
            image_index = 0;
            tocar_sfx("snd_souls_roll", 0.95, 1.08);
        }
        break;
        
    // --- NO AR ---
    case player_state.air:
        var touching_wall_right = place_meeting(x + 1, y, obj_colisor);
        var touching_wall_left  = place_meeting(x - 1, y, obj_colisor);
        
        if (vspd > 0 && !place_meeting(x, y - 2, obj_colisor) && ((touching_wall_right && move_dir > 0) || (touching_wall_left && move_dir < 0))) {
            state = player_state.wall_slide;
        }
        
        if (key_attack) {
            if (move_dir != 0) facing = move_dir;
            state = player_state.attack;
            action_timer = 24; 
            combo_count = 1;
            sprite_index = spr_player_attack_jump;
            image_index = 0;
            ataque_buffer = false;
            scale_x = escala_base * 1.25; scale_y = escala_base * 0.85;
            break;
        }
        
        var taxa_lerp = (move_dir != 0) ? accel : fric;
        hspd = lerp(hspd, move_dir * walk_sp, taxa_lerp);
        
        vspd += grv;
        if (vspd > max_vspd) vspd = max_vspd;
        if (key_jump_released && vspd < 0) { vspd *= 0.45; }
        
        image_blend = c_white;
        sprite_index = (vspd < 0) ? spr_player_jump : spr_player_air;
        
        if (on_ground && vspd >= 0) {
            scale_x = escala_base * 1.25; scale_y = escala_base * 0.80;
            state = (move_dir != 0) ? player_state.run : player_state.idle;
        }
        break;

    // --- ATTACK ---
    case player_state.attack:
        if (on_ground) {
            hspd = lerp(hspd, move_dir * (walk_sp * 0.5), 0.2); 
            vspd = 0;
        } else {
            vspd += grv;
            if (vspd > max_vspd) vspd = max_vspd;
            hspd = lerp(hspd, move_dir * walk_sp, 0.08); 
        }
        
        var _target_spr;
        if (!on_ground || sprite_index == spr_player_attack_jump) {
            _target_spr = spr_player_attack_jump;
        } else {
            _target_spr = (combo_count == 1) ? spr_player_attack : spr_player_attack2;
        }
        
        if (sprite_index != _target_spr) {
            sprite_index = _target_spr;
            image_index = 0;
        }
        image_blend = c_white;
        
        image_speed = (combo_count == 2) ? 0.95 : 1.15; 
        
        if (image_index >= image_number - 1) {
            image_index = image_number - 1;
            image_speed = 0;
        }
        
        if (key_attack) {
            ataque_buffer = true; 
        }
        
        // HITBOX COM ALCANCE VERTICAL AMPLIADO NO AR (ANTI-VESPA!)
        var _frame_hit = (combo_count == 2) ? 12 : 14;
        if (action_timer == _frame_hit) {
            tocar_sfx("snd_spear_thrust", (combo_count == 2) ? 1.1 : 0.94, (combo_count == 2) ? 1.2 : 1.04);
            var _offset_y = on_ground ? -12 : -24;
            var hit = instance_create_depth(x + (facing * 30), y + _offset_y, 0, obj_hitbox);
            hit.image_xscale = facing * (on_ground ? 1.5 : 1.9);
            hit.image_yscale = on_ground ? 1.0 : 2.4;
            hit.duracao = 6; 
            
            if (buff_fogo_timer > 0) hit.aplica_fogo = true;
            if (combo_count == 2) {
                hit.dano = 2; 
                hit.image_xscale = facing * 2.0;
            }
        }

        if (action_timer <= 10 && key_roll) {
            if (move_dir != 0) facing = move_dir;
            state = player_state.roll;
            action_timer = 14;
            is_invulnerable = true;
            iframe_timer = max(iframe_timer, 14);
            sprite_index = spr_player_roll;
            image_index = 0;
            image_speed = 1;
            tocar_sfx("snd_souls_roll", 0.95, 1.08);
            break;
        }

        action_timer--;
        
        if (action_timer <= 0) {
            if (ataque_buffer && combo_count == 1) {
                if (move_dir != 0) facing = move_dir;
                combo_count = 2;
                action_timer = 18;
                sprite_index = on_ground ? spr_player_attack2 : spr_player_attack_jump;
                image_index = 0;   
                ataque_buffer = false;
                if (on_ground) hspd = facing * 4.0;
                scale_x = escala_base * 1.35; scale_y = escala_base * 0.80;
            } else {
                combo_count = 0;
                image_speed = 1; 
                state = on_ground ? ((move_dir != 0) ? player_state.run : player_state.idle) : player_state.air;
            }
        }
        break;

    // --- ROLANDO ---
    case player_state.roll:
        if (sprite_index != spr_player_roll) {
            sprite_index = spr_player_roll;
            image_index = 0;
        }
        
        image_speed = 1.0; 
        if (image_index >= image_number - 1) {
            image_index = image_number - 1;
            image_speed = 0;
        }
        
        hspd = facing * roll_sp; 
        vspd += grv; 
        image_blend = c_white;
        
        action_timer--;
        
        if (action_timer <= 0) { 
            image_speed = 1.0;
            if (iframe_timer <= 10) {
                iframe_timer = 0;
                is_invulnerable = false;
            }
            state = on_ground ? ((move_dir != 0) ? player_state.run : player_state.idle) : player_state.air; 
        }
        break;

    // --- WALL SLIDE ---
    case player_state.wall_slide:
        vspd = 2; 
        hspd = 0;
        image_blend = c_white;
        sprite_index = spr_player_jump;
        var wall_dir = place_meeting(x + 1, y, obj_colisor) ? 1 : -1;
        
        if (key_jump) {
            vspd = wall_jump_vspd;
            hspd = -wall_dir * wall_jump_hspd;
            facing = -wall_dir;
            x += -wall_dir * 2; 
            scale_x = escala_base * 0.80; scale_y = escala_base * 1.25;
            tocar_sfx("snd_pogo_bounce", 0.95, 1.1);
            state = player_state.air;
            break;
        }
        
        if (move_dir != wall_dir || !place_meeting(x + wall_dir, y, obj_colisor) || on_ground) {
            state = player_state.air;
        }
        break;

    // --- HUB DO PERSONAGEM (TELA DE CRAFTING / INVENTÁRIO) ---
    case player_state.menu:
        hspd = 0; vspd = 0; 
        sprite_index = spr_player_idle;
        
        if (key_tab_right || keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) { aba_atual++; if (aba_atual > 2) aba_atual = 0; menu_index = 0; tocar_sfx("snd_ui_move"); }
        if (key_tab_left  || keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) { aba_atual--; if (aba_atual < 0) aba_atual = 2; menu_index = 0; tocar_sfx("snd_ui_move"); }
        
        if (keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_face2)) {
            tocar_sfx("snd_ui_back", 0.95, 1.05);
            state = player_state.idle;
            instance_activate_all();
            keyboard_clear(vk_escape);
            exit;
        }
        
        if (aba_atual == 1) {
            if (key_down) { menu_index++; if (menu_index >= array_length(craft_recipes)) menu_index = 0; tocar_sfx("snd_ui_move"); }
            if (key_up)   { menu_index--; if (menu_index < 0) menu_index = array_length(craft_recipes) - 1; tocar_sfx("snd_ui_move"); }
            
            if (key_confirm) {
                var cost = craft_cost_array[menu_index];
                var tem_material = false;
                if (menu_index == 0 && carne_count >= 1)    tem_material = true;
                if (menu_index == 1 && glandula_count >= 1) tem_material = true;
                if (menu_index == 2 && ferrao_count >= 1)   tem_material = true;
                
                if (global.scrap >= cost && tem_material) {
                    global.scrap -= cost;
                    if (menu_index == 0) carne_count--;
                    if (menu_index == 1) glandula_count--;
                    if (menu_index == 2) ferrao_count--;
                    
                    craft_cost = cost;
                    craft_selected_item = menu_index;
                    craft_timer = 0;
                    tocar_sfx("snd_craft_hammer", 0.95, 1.05);
                    state = player_state.craft; 
                } else {
                    tocar_sfx("snd_craft_fail", 0.95, 1.05);
                }
            }
        }
        exit;

    // --- FABRICANDO ITEM ---
    case player_state.craft:
        hspd = 0; vspd = 0; 
        image_blend = c_white; 
        sprite_index = spr_player_idle;
        craft_timer += 2;
        
        if (craft_timer == 22) {
            tocar_sfx("snd_craft_hammer", 1.05, 1.15);
        }
        
        if (craft_timer >= craft_time_max) {
            if (craft_selected_item == 0) curativo_count++;
            else if (craft_selected_item == 1) molotov_count++;
            else if (craft_selected_item == 2) faca_count++;
            craft_timer = 0;
            tocar_sfx("snd_craft_success", 0.98, 1.05);
            state = player_state.menu; 
        }
        exit;
}

// =====================================================================
// 4. DANO E I-FRAMES
// =====================================================================
if (is_invulnerable) {
    iframe_timer--;
    if (iframe_timer <= 0) is_invulnerable = false;
}

if (!is_invulnerable && state != player_state.roll) {
    if (object_exists(obj_acido_centopeia)) {
        var gota_acido = instance_place(x, y, obj_acido_centopeia);
        if (gota_acido != noone) {
            hp -= gota_acido.dano;
            is_invulnerable = true;
            iframe_timer = 60; 
            var dir_acido = (gota_acido.hspd != 0) ? sign(gota_acido.hspd) : -facing;
            hspd = dir_acido * 5;
            vspd = -4;
            state = player_state.air;
            tocar_sfx("snd_mouse_hurt", 0.9, 1.05);
            instance_destroy(gota_acido);
        }
    }
    
    if (object_exists(obj_espinho) && place_meeting(x, y, obj_espinho)) {
        hp -= 20; 
        is_invulnerable = true; 
        iframe_timer = 65; 
        vspd = -5; 
        hspd = -facing * 6; 
        state = player_state.air; 
        tocar_sfx("snd_mouse_hurt", 0.9, 1.05);
    }
    
    var inimigo = instance_place(x, y, obj_enemy);
    if (inimigo != noone && inimigo.object_index != obj_boss_centopeia) {
        if (inimigo.state == enemy_state.charge) {
            hp -= 15;
            is_invulnerable = true;
            iframe_timer = 65; 
            var dir_hit = sign(x - inimigo.x);
            if (dir_hit == 0) dir_hit = -facing;
            hspd = dir_hit * 6.5;
            vspd = -4.5;
            state = player_state.air;
            inimigo.hspd = -dir_hit * 5;
            inimigo.vspd = -2.5;
            tocar_sfx("snd_mouse_hurt", 0.9, 1.05);
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 5;
                obj_game_controller.shake_magnitude = 3;
            }
        }
    }
    
    if (object_exists(obj_vespa)) {
        var vespa = instance_place(x, y, obj_vespa);
        if (vespa != noone) {
            hp -= 15;
            is_invulnerable = true;
            iframe_timer = 65; 
            var dir_v = sign(x - vespa.x);
            if (dir_v == 0) dir_v = -facing;
            hspd = dir_v * 6.5;
            vspd = -4.5;
            state = player_state.air;
            tocar_sfx("snd_mouse_hurt", 0.9, 1.05);
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 5;
                obj_game_controller.shake_magnitude = 3;
            }
        }
    }
}

// =====================================================================
// GATILHO DE MORTE (ACIONA A TABELA TOP 5 DO CONTROLLER)
// =====================================================================
if (hp <= 0) {
    hp = 0;
    hspd = 0;
    vspd = 0;
    tocar_sfx("snd_mouse_hurt", 0.7, 0.85);
    
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.is_dead = true;
        obj_game_controller.motivo_derrota = 1; // 1 = Player morreu
        obj_game_controller.death_index = 0;
        obj_game_controller.death_alpha = 0;
        obj_game_controller.hitstop_timer = 0;
        instance_deactivate_all(true);
        instance_activate_object(obj_game_controller);
    } else {
        room_restart();
    }
    exit;
}

// =====================================================================
// 5. APLICAÇÃO FÍSICA
// =====================================================================
if (place_meeting(x, y, obj_colisor)) {
    for (var d = 1; d <= 16; d++) {
        if (!place_meeting(x + d, y, obj_colisor)) { x += d; break; }
        if (!place_meeting(x - d, y, obj_colisor)) { x -= d; break; }
        if (!place_meeting(x, y + d, obj_colisor)) { y += d; break; }
        if (!place_meeting(x, y - d, obj_colisor)) { y -= d; break; }
    }
}

if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) { x += sign(hspd); }
    hspd = 0;
}
x += hspd;

if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) { y += sign(vspd); }
    vspd = 0;
}
y += vspd;

if (keyboard_check_pressed(ord("U"))) { 
    repeat(3) { instance_create_depth(x, y - 10, 0, obj_scrap); } 
    carne_count++;
    glandula_count++;
    ferrao_count++;
    tocar_sfx("snd_craft_pickup", 1.0, 1.2);
}

scale_x = lerp(scale_x, escala_base, 0.2);
scale_y = lerp(scale_y, escala_base, 0.2);
image_xscale = facing * scale_x;
image_yscale = scale_y;