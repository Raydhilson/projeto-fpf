// =====================================================================
// 0. SISTEMA DE HITSTOP E DROP-IN DO PLAYER 2 (F2 ou START no Controle 2)
// =====================================================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

// Se só existe o Player 1 na sala, apertar F2 ou Start no Controle 1 cria o Player 2!
if (player_id == 0 && instance_number(obj_player) < 2) {
    if (keyboard_check_pressed(vk_f2) || gamepad_button_check_pressed(1, gp_start)) {
        instance_create_layer(x - (facing * 24), y, layer, obj_player, {
            player_id : 1
        });
    }
}

// =====================================================================
// 1. LEITURA DE CONTROLES SEPARADA POR JOGADOR (P1 vs P2)
// =====================================================================
var move_dir          = 0;
var key_jump          = false;
var key_jump_released = false;
var key_attack        = false;
var key_roll          = false;
var key_throw         = false;
var key_menu          = false;
var key_heal          = false;
var key_up            = false;
var key_down          = false;
var key_confirm       = false;
var key_tab_left      = false;
var key_tab_right     = false;

var deadzone = 0.2;

if (player_id == 0) {
    // --- CONTROLES DO PLAYER 1 (Teclado Principal + Gamepad 0) ---
    move_dir = keyboard_check(global.key_right) - keyboard_check(global.key_left);
    if (move_dir == 0) {
        var axis_h = gamepad_axis_value(0, gp_axislh);
        if (abs(axis_h) > deadzone) move_dir = sign(axis_h);
    }

    key_jump          = keyboard_check_pressed(global.key_jump)    || gamepad_button_check_pressed(0, gp_face1);
    key_jump_released = keyboard_check_released(global.key_jump)   || gamepad_button_check_released(0, gp_face1);
    key_attack        = keyboard_check_pressed(global.key_attack)  || gamepad_button_check_pressed(0, gp_face3);
    key_roll          = keyboard_check_pressed(global.key_roll)    || gamepad_button_check_pressed(0, gp_face2);
    key_throw         = keyboard_check_pressed(global.key_throw)   || gamepad_button_check_pressed(0, gp_shoulderr);
    key_menu          = keyboard_check_pressed(global.key_menu)    || gamepad_button_check_pressed(0, gp_start);
    key_heal          = keyboard_check_pressed(global.key_heal)    || gamepad_button_check_pressed(0, gp_padl);
    key_up            = keyboard_check_pressed(global.key_up)      || keyboard_check_pressed(ord("W")) || gamepad_button_check_pressed(0, gp_padu);
    key_down          = keyboard_check_pressed(global.key_down)    || keyboard_check_pressed(ord("S")) || gamepad_button_check_pressed(0, gp_padd);
    key_confirm       = keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);
    key_tab_left      = keyboard_check_pressed(global.key_tab_left)  || gamepad_button_check_pressed(0, gp_shoulderl);
    key_tab_right     = keyboard_check_pressed(global.key_tab_right) || gamepad_button_check_pressed(0, gp_shoulderr);
} else {
    // --- CONTROLES DO PLAYER 2 (Gamepad 1 + Setas/Numpad para Teste no Teclado) ---
    move_dir = keyboard_check(vk_right) - keyboard_check(vk_left);
    if (move_dir == 0) {
        var axis_h = gamepad_axis_value(1, gp_axislh);
        if (abs(axis_h) > deadzone) move_dir = sign(axis_h);
        if (gamepad_button_check(1, gp_padr)) move_dir = 1;
        if (gamepad_button_check(1, gp_padl)) move_dir = -1;
    }

    key_jump          = keyboard_check_pressed(vk_numpad0)   || keyboard_check_pressed(vk_rshift)   || gamepad_button_check_pressed(1, gp_face1);
    key_jump_released = keyboard_check_released(vk_numpad0)  || keyboard_check_released(vk_rshift)  || gamepad_button_check_released(1, gp_face1);
    key_attack        = keyboard_check_pressed(vk_numpad1)   || keyboard_check_pressed(vk_rcontrol) || gamepad_button_check_pressed(1, gp_face3);
    key_roll          = keyboard_check_pressed(vk_numpad2)   || keyboard_check_pressed(vk_ralt)     || gamepad_button_check_pressed(1, gp_face2);
    key_throw         = keyboard_check_pressed(vk_numpad3)   || gamepad_button_check_pressed(1, gp_shoulderr);
    key_menu          = keyboard_check_pressed(vk_numpad9)   || gamepad_button_check_pressed(1, gp_start);
    key_heal          = keyboard_check_pressed(vk_numpad4)   || gamepad_button_check_pressed(1, gp_padl);
    key_up            = keyboard_check_pressed(vk_up)        || gamepad_button_check_pressed(1, gp_padu);
    key_down          = keyboard_check_pressed(vk_down)      || gamepad_button_check_pressed(1, gp_padd);
    key_confirm       = keyboard_check_pressed(vk_numpad5)   || gamepad_button_check_pressed(1, gp_face1);
    key_tab_left      = keyboard_check_pressed(vk_numpad7)   || gamepad_button_check_pressed(1, gp_shoulderl);
    key_tab_right     = keyboard_check_pressed(vk_numpad8)   || gamepad_button_check_pressed(1, gp_shoulderr);
}

// Permite virar de lado livremente (inclusive no início do ataque para Kite!)
if (move_dir != 0 && state != player_state.menu && state != player_state.craft && state != player_state.roll) { 
    if (state != player_state.attack || action_timer >= 12) {
        facing = move_dir; 
    }
}

// =====================================================================
// 2. USO DE ITENS (CURATIVO), BUFFS E TIMERS FÍSICOS
// =====================================================================
if (state != player_state.menu && key_heal && curativo_count > 0 && hp < hp_max) {
    curativo_count--;
    hp = min(hp + 30, hp_max);
}

if (buff_fogo_timer > 0 && state != player_state.menu) {
    buff_fogo_timer--;
}

var on_ground = place_meeting(x, y + 1, obj_colisor);
if (on_ground) { coyote_timer = coyote_time_max; } else { coyote_timer = max(0, coyote_timer - 1); }
if (key_jump)  { jump_buffer_timer = jump_buffer_max; } else { jump_buffer_timer = max(0, jump_buffer_timer - 1); }

// Estamina
if (stamina_delay_timer > 0) {
    stamina_delay_timer--;
} else {
    if (stamina_current < stamina_max && state != player_state.roll) {
        stamina_current += stamina_regen_rate;
        if (stamina_current > stamina_max) stamina_current = stamina_max;
    }
}
if (stamina_current <= 0) { stamina_current = 0; stamina_exhausted = true; }
if (stamina_exhausted && stamina_current >= stamina_recovery_threshold) { stamina_exhausted = false; }

// Menu
if (key_menu && on_ground && state != player_state.attack && state != player_state.roll) {
    if (state != player_state.menu) { state = player_state.menu; hspd = 0; menu_index = 0; } 
    else { state = player_state.idle; }
}

// =====================================================================
// 3. MÁQUINA DE ESTADOS (FSM)
// =====================================================================
switch (state) {
    
    // --- PARADO ---
    case player_state.idle:
        hspd = lerp(hspd, 0, fric); 
        if (abs(hspd) < 0.1) hspd = 0;
        
        image_blend = base_blend;
        sprite_index = spr_player_idle;
        
        if (move_dir != 0) state = player_state.run;
        if (!on_ground) state = player_state.air; 
        
        if (jump_buffer_timer > 0 && coyote_timer > 0) { 
            vspd = jump_spd; jump_buffer_timer = 0; coyote_timer = 0;
            scale_x = 0.75; scale_y = 1.35; state = player_state.air; 
        }
        
        if (key_attack && !stamina_exhausted && stamina_current >= stamina_cost_attack) {
            if (move_dir != 0) facing = move_dir;
            stamina_current -= stamina_cost_attack;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.attack;
            action_timer = 14; 
            combo_count = 1;       
            sprite_index = spr_player_attack;
            image_index = 0;       
            ataque_buffer = false; 
            hspd = facing * 3.0; 
            scale_x = 1.25; scale_y = 0.85;
        }
        
        if (key_throw) {
            if (faca_count > 0 && object_exists(obj_faca_arremesso)) {
                faca_count--;
                var faca = instance_create_layer(x + (facing * 12), y - 14, "Instances", obj_faca_arremesso);
                faca.hspd = facing * 11; faca.vspd = -1;
            } else if (molotov_count > 0 && object_exists(obj_molotov)) {
                molotov_count--;
                var molotov = instance_create_layer(x + (facing * 10), y - 15, "Instances", obj_molotov);
                molotov.hspd = facing * 6.5; molotov.vspd = -4.5;         
            }
        }
        
        if (key_roll && !stamina_exhausted && stamina_current >= stamina_cost_roll) {
            stamina_current -= stamina_cost_roll; 
            stamina_delay_timer = stamina_delay_max;
            state = player_state.roll; 
            action_timer = 18; 
            is_invulnerable = true; 
            iframe_timer = max(iframe_timer, 28); 
            sprite_index = spr_player_roll; 
            image_index = 0;
        }
        break;
        
    // --- CORRENDO ---
    case player_state.run:
        hspd = lerp(hspd, move_dir * walk_sp, accel); 
        image_blend = base_blend;
        sprite_index = spr_player_walk;
        
        if (move_dir == 0) state = player_state.idle;
        if (!on_ground) state = player_state.air;
        
        if (jump_buffer_timer > 0 && coyote_timer > 0) { 
            vspd = jump_spd; jump_buffer_timer = 0; coyote_timer = 0;
            scale_x = 0.75; scale_y = 1.35; state = player_state.air; 
        }
        
        if (key_attack && !stamina_exhausted && stamina_current >= stamina_cost_attack) {
            if (move_dir != 0) facing = move_dir;
            stamina_current -= stamina_cost_attack;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.attack;
            action_timer = 14;
            combo_count = 1;       
            sprite_index = spr_player_attack;
            image_index = 0;
            ataque_buffer = false;
            
            hspd = facing * 3.5;
            scale_x = 1.25;
            scale_y = 0.85;
        }

        if (key_throw) {
            if (faca_count > 0 && object_exists(obj_faca_arremesso)) {
                faca_count--;
                var faca = instance_create_layer(x + (facing * 12), y - 14, "Instances", obj_faca_arremesso);
                faca.hspd = facing * 12; faca.vspd = -1;
            } else if (molotov_count > 0 && object_exists(obj_molotov)) {
                molotov_count--;
                var molotov = instance_create_layer(x + (facing * 10), y - 15, "Instances", obj_molotov);
                molotov.hspd = facing * 8; molotov.vspd = -4;         
            }
        }
        
        if (key_roll && !stamina_exhausted && stamina_current >= stamina_cost_roll) {
            stamina_current -= stamina_cost_roll; stamina_delay_timer = stamina_delay_max;
            state = player_state.roll; action_timer = 18; is_invulnerable = true; iframe_timer = max(iframe_timer, 28);
            sprite_index = spr_player_roll; image_index = 0;
        }
        break;
        
    // --- NO AR ---
    case player_state.air:
        var touching_wall_right = place_meeting(x + 1, y, obj_colisor);
        var touching_wall_left  = place_meeting(x - 1, y, obj_colisor);
        
        if (vspd > 0 && !place_meeting(x, y - 2, obj_colisor) && ((touching_wall_right && move_dir > 0) || (touching_wall_left && move_dir < 0))) {
            state = player_state.wall_slide;
        }
        
        if (key_attack && !stamina_exhausted && stamina_current >= stamina_cost_attack) {
            if (move_dir != 0) facing = move_dir;
            stamina_current -= stamina_cost_attack;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.attack;
            action_timer = 14;
            combo_count = 1;
            sprite_index = spr_player_attack;
            image_index = 0;
            ataque_buffer = false;
            scale_x = 1.25; scale_y = 0.85;
        }
        
        var taxa_lerp = (move_dir != 0) ? accel : fric;
        hspd = lerp(hspd, move_dir * walk_sp, taxa_lerp);
        
        vspd += grv;
        if (vspd > max_vspd) vspd = max_vspd;
        if (key_jump_released && vspd < 0) { vspd *= 0.45; }
        
        image_blend = base_blend;
        sprite_index = (vspd < 0) ? spr_player_jump : spr_player_air;
        
        if (on_ground && vspd >= 0) {
            scale_x = 1.25; scale_y = 0.80;
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
            hspd = lerp(hspd, move_dir * walk_sp, 0.08); 
        }
        
        sprite_index = (combo_count == 1) ? spr_player_attack : spr_player_attack2;
        image_blend = base_blend;
        
        if (key_attack && arma_nivel >= 2) {
            ataque_buffer = true; 
        }
        
        if (action_timer == 12) {
            var hit = instance_create_layer(x + (facing * 26), y - 12, "Instances", obj_hitbox);
            hit.image_xscale = facing * 1.5;
            hit.duracao = 5; 
            
            if (buff_fogo_timer > 0) hit.aplica_fogo = true;
            if (combo_count == 2) {
                hit.dano = 2; 
                hit.image_xscale = facing * 1.8;
            }
        }

        if (action_timer <= 9 && key_roll && !stamina_exhausted && stamina_current >= stamina_cost_roll) {
            if (move_dir != 0) facing = move_dir;
            stamina_current -= stamina_cost_roll;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.roll;
            action_timer = 18;
            is_invulnerable = true;
            iframe_timer = max(iframe_timer, 28);
            sprite_index = spr_player_roll;
            image_index = 0;
            break;
        }

        action_timer--;
        
        if (action_timer <= 0) {
            if (ataque_buffer && combo_count == 1 && arma_nivel >= 2) {
                if (move_dir != 0) facing = move_dir;
                combo_count = 2;
                action_timer = 14; 
                sprite_index = spr_player_attack2;
                image_index = 0;   
                ataque_buffer = false;
                hspd = facing * 4.0;
                scale_x = 1.35; scale_y = 0.80;
            } else {
                combo_count = 0;
                state = on_ground ? ((move_dir != 0) ? player_state.run : player_state.idle) : player_state.air;
            }
        }
        break;

    // --- ROLANDO ---
    case player_state.roll:
        hspd = facing * roll_sp; 
        vspd = 0; 
        image_blend = base_blend;
        sprite_index = spr_player_roll;
        
        action_timer--;
        if (action_timer <= 0) { 
            state = on_ground ? ((move_dir != 0) ? player_state.run : player_state.idle) : player_state.air; 
        }
        break;

    // --- ESCORREGANDO NA PAREDE ---
    case player_state.wall_slide:
        vspd = 2; 
        hspd = 0;
        image_blend = base_blend;
        sprite_index = spr_player_jump;
        var wall_dir = place_meeting(x + 1, y, obj_colisor) ? 1 : -1;
        
        if (key_jump) {
            vspd = wall_jump_vspd;
            hspd = -wall_dir * wall_jump_hspd;
            facing = -wall_dir;
            x += -wall_dir * 2; 
            scale_x = 0.80; scale_y = 1.25;
            state = player_state.air;
            break;
        }
        
        if (move_dir != wall_dir || !place_meeting(x + wall_dir, y, obj_colisor) || on_ground) {
            state = player_state.air;
        }
        break;

    // --- HUB DO PERSONAGEM ---
    case player_state.menu:
        hspd = 0; vspd = 0; 
        sprite_index = spr_player_idle;
        
        if (key_tab_right) { aba_atual++; if (aba_atual > 2) aba_atual = 0; }
        if (key_tab_left)  { aba_atual--; if (aba_atual < 0) aba_atual = 2; }
        
        if (aba_atual == 1) {
            if (key_down) { menu_index++; if (menu_index >= array_length(craft_recipes)) menu_index = 0; }
            if (key_up)   { menu_index--; if (menu_index < 0) menu_index = array_length(craft_recipes) - 1; }
            
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
                    state = player_state.craft; 
                }
            }
        }
        break;

    // --- FABRICANDO ITEM ---
    case player_state.craft:
        hspd = 0; vspd = 0; 
        image_blend = base_blend; 
        sprite_index = spr_player_idle;
        craft_timer++; 
        if (craft_timer >= craft_time_max) {
            if (craft_selected_item == 0) curativo_count++;
            else if (craft_selected_item == 1) molotov_count++;
            else if (craft_selected_item == 2) faca_count++;
            craft_timer = 0;
            state = player_state.idle; 
        }
        break;
}

// =====================================================================
// 4. SISTEMAS DE DANO DE COMBATE E I-FRAMES
// =====================================================================
if (is_invulnerable) {
    iframe_timer--;
    if (iframe_timer <= 0) is_invulnerable = false;
}

if (!is_invulnerable && state != player_state.roll) {
    
    // 1. Dano do Projétil de Ácido
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
            instance_destroy(gota_acido);
        }
    }
    
    // 2. Dano de Espinhos
    if (object_exists(obj_espinho) && place_meeting(x, y, obj_espinho)) {
        hp -= 20; 
        is_invulnerable = true; 
        iframe_timer = 65; 
        vspd = -5; 
        hspd = -facing * 6; 
        state = player_state.air; 
    }
    
    // 3. Dano do Chefe: Centopeia Alfa
    var boss = object_exists(obj_boss_centopeia) ? instance_place(x, y, obj_boss_centopeia) : noone;
    if (boss != noone) {
        if (boss.state == centopeia_state.investida || boss.state == centopeia_state.emergindo) {
            var dano_boss = (boss.state == centopeia_state.investida) ? 25 : 20;
            hp -= dano_boss;
            is_invulnerable = true;
            iframe_timer = 75; 
            
            var dir_empurrao = sign(x - boss.x);
            if (dir_empurrao == 0) dir_empurrao = -facing;
            
            hspd = dir_empurrao * 7.5;
            vspd = -5.5;
            state = player_state.air;
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 6;
                obj_game_controller.shake_magnitude = 5;
            }
        }
    }
    
    // 4. Dano de Inimigos Comuns
    var inimigo = instance_place(x, y, obj_enemy);
    if (inimigo == noone && object_exists(obj_vespa)) {
        inimigo = instance_place(x, y, obj_vespa);
    }
    
    if (inimigo != noone && inimigo != boss && inimigo.object_index != obj_boss_centopeia) {
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
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.hitstop_timer = 5;
            obj_game_controller.shake_magnitude = 3;
        }
    }
}

// Controle de Morte (No Co-op, se tiver outro jogador vivo, apenas destrói quem morreu; se todos morrerem, reinicia!)
if (hp <= 0) {
    hp = 0;
    if (instance_number(obj_player) > 1) {
        instance_destroy();
        exit;
    } else {
        if (file_exists("save_1.ini")) {
            carregar_jogo(1);
        } else {
            room_restart();
        }
    }
}

// =====================================================================
// 5. APLICAÇÃO FÍSICA UNIFICADA
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
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) { 
        x += sign(hspd); 
    }
    hspd = 0;
}
x += hspd;

if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) { 
        y += sign(vspd); 
    }
    vspd = 0;
}
y += vspd;

// Gerar sucata e drops orgânicos de teste (Tecla U)
if (keyboard_check_pressed(ord("U"))) { 
    repeat(3) { instance_create_layer(x, y - 10, "Instances", obj_scrap); } 
    carne_count++;
    glandula_count++;
    ferrao_count++;
}

// Squash & Stretch
scale_x = lerp(scale_x, 1.0, 0.2);
scale_y = lerp(scale_y, 1.0, 0.2);