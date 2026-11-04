// =====================================================================
// 0. SISTEMA DE HITSTOP (PAUSA O RATO)
// =====================================================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit; // Corta a leitura deste script agora!
} else {
    image_speed = 1;
}

// =====================================================================
// 1. LEITURA DE CONTROLES E DIREÇÃO
// =====================================================================
var move_dir = keyboard_check(vk_right) - keyboard_check(vk_left);

if (move_dir == 0) {
    var deadzone = 0.2;
    var axis_h = gamepad_axis_value(0, gp_axislh);
    if (abs(axis_h) > deadzone) { move_dir = sign(axis_h); }
}

if (move_dir != 0 && state != player_state.menu && state != player_state.craft) { 
    facing = move_dir; 
}

var key_jump          = keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);
var key_jump_released = keyboard_check_released(vk_space) || gamepad_button_check_pressed(0, gp_face1); 
var key_attack        = keyboard_check_pressed(ord("J"))  || gamepad_button_check_pressed(0, gp_face3); 
var key_roll          = keyboard_check_pressed(ord("K"))  || gamepad_button_check_pressed(0, gp_face2); 
var key_throw         = keyboard_check_pressed(ord("F"))  || gamepad_button_check_pressed(0, gp_shoulderr);

// Hub do Personagem (Inventário/Maestria) no I ou Select do comando
var key_menu    = keyboard_check_pressed(ord("I")) || gamepad_button_check_pressed(0, gp_select);
var key_heal    = keyboard_check_pressed(ord("Q")) || gamepad_button_check_pressed(0, gp_padl);
var key_up      = keyboard_check_pressed(vk_up)    || gamepad_button_check_pressed(0, gp_padu);
var key_down    = keyboard_check_pressed(vk_down)  || gamepad_button_check_pressed(0, gp_padd);
var key_confirm = keyboard_check_pressed(vk_enter) || gamepad_button_check_pressed(0, gp_face1);

// Teclas de Aba (LB / RB ou Q / E)
var key_tab_left  = keyboard_check_pressed(ord("Q")) || gamepad_button_check_pressed(0, gp_shoulderl);
var key_tab_right = keyboard_check_pressed(ord("E")) || gamepad_button_check_pressed(0, gp_shoulderr);

// =====================================================================
// 2. USO DE ITENS (CURATIVO), BUFFS E TIMERS FÍSICOS
// =====================================================================
if (state != player_state.menu && key_heal && curativo_count > 0 && hp < hp_max) {
    curativo_count--;
    hp = min(hp + 30, hp_max);
    show_debug_message("Curou! HP atual: " + string(hp));
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
        
        image_blend = c_white;
        sprite_index = spr_player_idle;
        
        if (move_dir != 0) state = player_state.run;
        if (!on_ground) state = player_state.air; 
        
        if (jump_buffer_timer > 0 && coyote_timer > 0) { 
            vspd = jump_spd; jump_buffer_timer = 0; coyote_timer = 0;
            scale_x = 0.75; scale_y = 1.35; state = player_state.air; 
        }
        
        // ATAQUE INICIAL
        if (key_attack && !stamina_exhausted && stamina_current >= stamina_cost_attack) {
            stamina_current -= stamina_cost_attack;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.attack;
            action_timer = 15; 
            combo_count = 1;       
            sprite_index = spr_player_attack;
            image_index = 0;       
            ataque_buffer = false; 
        }
        
        if (key_throw && molotov_count > 0) {
            molotov_count--;
            var molotov = instance_create_layer(x + (facing * 10), y - 15, "Instances", obj_molotov);
            molotov.hspd = facing * 6; molotov.vspd = -5;         
        }
        
        if (key_roll && !stamina_exhausted && stamina_current >= stamina_cost_roll) {
            stamina_current -= stamina_cost_roll; stamina_delay_timer = stamina_delay_max;
            state = player_state.roll; action_timer = 20; is_invulnerable = true; iframe_timer = 25;
            sprite_index = spr_player_roll;
            image_index = 0;
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
            scale_x = 0.75; scale_y = 1.35; state = player_state.air; 
        }
        
        // ATAQUE INICIAL CORRENDO
        if (key_attack && !stamina_exhausted && stamina_current >= stamina_cost_attack) {
            stamina_current -= stamina_cost_attack;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.attack;
            action_timer = 15;
            combo_count = 1;       
            sprite_index = spr_player_attack;
            image_index = 0;
            ataque_buffer = false;
        }

        if (key_throw && molotov_count > 0) {
            molotov_count--;
            var molotov = instance_create_layer(x + (facing * 10), y - 15, "Instances", obj_molotov);
            molotov.hspd = facing * 8; molotov.vspd = -4;         
        }
        
        if (key_roll && !stamina_exhausted && stamina_current >= stamina_cost_roll) {
            stamina_current -= stamina_cost_roll; stamina_delay_timer = stamina_delay_max;
            state = player_state.roll; action_timer = 20; is_invulnerable = true; iframe_timer = 25;
            sprite_index = spr_player_roll;
            image_index = 0;
        }
        break;
        
    // --- NO AR (COM COLISÃO SEGURA PARA A QUEDA) ---
    case player_state.air:
        var touching_wall_right = place_meeting(x + 1, y, obj_colisor);
        var touching_wall_left  = place_meeting(x - 1, y, obj_colisor);
        
        if (vspd > 0 && ((touching_wall_right && move_dir > 0) || (touching_wall_left && move_dir < 0))) {
            state = player_state.wall_slide;
        }
        
        // ATAQUE NO AR
        if (key_attack && !stamina_exhausted && stamina_current >= stamina_cost_attack) {
            stamina_current -= stamina_cost_attack;
            stamina_delay_timer = stamina_delay_max;
            state = player_state.attack;
            action_timer = 15;
            combo_count = 1;
            sprite_index = spr_player_attack;
            image_index = 0;
            ataque_buffer = false;
        }
        
        var taxa_lerp = (move_dir != 0) ? accel : fric;
        hspd = lerp(hspd, move_dir * walk_sp, taxa_lerp);
        
        vspd += grv;
        if (vspd > max_vspd) vspd = max_vspd;
        
        if (key_jump_released && vspd < 0) { vspd *= 0.45; }
        
        // TROCA DE SPRITE: SUBIDA VS QUEDA
        image_blend = c_white;
        if (vspd < 0) {
            sprite_index = spr_player_jump; // Subindo
            image_speed = 1;
        } else {
            sprite_index = spr_player_air;  // Caindo
            image_speed = 1;
        }
        
        // COLISÃO VERTICAL SEGURA (Garante que não afunda no bloco)
        if (place_meeting(x, y + vspd, obj_colisor)) {
            while (!place_meeting(x, y + sign(vspd), obj_colisor)) { 
                y += sign(vspd); 
            }
            vspd = 0; 
            scale_x = 1.35; 
            scale_y = 0.75; 
            state = (move_dir != 0) ? player_state.run : player_state.idle;
        }
        break;

    // --- ATTACK (Combos e Hitbox) ---
    case player_state.attack:
        if (place_meeting(x, y + 1, obj_colisor)) {
            hspd = lerp(hspd, 0, 0.15); 
            vspd = 0;
        } else {
            vspd += grv;
            hspd = lerp(hspd, 0, 0.05); 
        }
        
        if (combo_count == 1) {
            sprite_index = spr_player_attack;
        } else {
            sprite_index = spr_player_attack2;
        }
        image_blend = c_white;
        
        if (key_attack && arma_nivel >= 2) {
            ataque_buffer = true; 
        }
        
        // CRIA A HITBOX (Frame 10 da animação)
        if (action_timer == 10) {
            var hit = instance_create_layer(x + (facing * 16), y - 10, "Instances", obj_hitbox);
            hit.image_xscale = facing;
            
            if (buff_fogo_timer > 0) {
                hit.aplica_fogo = true;
            }
            
            if (combo_count == 2) {
                hit.dano = 2; 
                hit.image_xscale = facing * 1.5; 
            }
        }

        action_timer--;
        
        if (action_timer <= 0) {
            if (ataque_buffer && combo_count == 1 && arma_nivel >= 2) {
                combo_count = 2;
                action_timer = 15; 
                sprite_index = spr_player_attack2;
                image_index = 0;   
                ataque_buffer = false;
                hspd = facing * 4; 
            } else {
                if (image_index >= image_number - 1) {
                    combo_count = 0;
                    sprite_index = spr_player_idle;
                    if (place_meeting(x, y + 1, obj_colisor)) {
                        state = (move_dir != 0) ? player_state.run : player_state.idle;
                    } else {
                        state = player_state.air;
                    }
                }
            }
        }
        break;

    // --- ROLANDO ---
    case player_state.roll:
        hspd = facing * roll_sp; 
        vspd = 0; 
        image_blend = c_white;
        sprite_index = spr_player_roll;
        
        action_timer--;
        if (action_timer <= 0 && image_index >= image_number - 1) { 
            state = (move_dir != 0) ? player_state.run : player_state.idle; 
        }
        break;

    // --- ESCORREGANDO NA PAREDE ---
    case player_state.wall_slide:
        vspd = 2; 
        image_blend = c_white;
        sprite_index = spr_player_jump;
        var wall_dir = place_meeting(x + 1, y, obj_colisor) ? 1 : -1;
        
        if (key_jump) {
            vspd = wall_jump_vspd; hspd = -wall_dir * wall_jump_hspd; facing = -wall_dir;
            scale_x = 0.75; scale_y = 1.35; state = player_state.air;
        }
        
        if (move_dir != wall_dir || !place_meeting(x + wall_dir, y, obj_colisor) || place_meeting(x, y + 1, obj_colisor)) {
            state = player_state.air;
        }
        break;

    // --- HUB DO PERSONAGEM (MENU EM ABAS) ---
    case player_state.menu:
        hspd = 0; vspd = 0; 
        sprite_index = spr_player_idle;
        
        if (key_tab_right) {
            aba_atual++;
            if (aba_atual > 2) aba_atual = 0;
        }
        if (key_tab_left) {
            aba_atual--;
            if (aba_atual < 0) aba_atual = 2;
        }
        
        if (aba_atual == 1) {
            if (key_down) { menu_index++; if (menu_index >= array_length(craft_recipes)) menu_index = 0; }
            if (key_up) { menu_index--; if (menu_index < 0) menu_index = array_length(craft_recipes) - 1; }
            
            if (key_confirm) {
                var cost = craft_cost_array[menu_index];
                if (global.scrap >= cost) {
                    global.scrap -= cost;
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
        image_blend = c_white; 
        sprite_index = spr_player_idle;
        craft_timer++; 
        if (craft_timer >= craft_time_max) {
            if (craft_selected_item == 0) { curativo_count++; show_debug_message("Curativo feito!"); }
            else if (craft_selected_item == 1) { molotov_count++; show_debug_message("Molotov feito!"); }
            craft_timer = 0; state = player_state.idle; 
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

// Checagem de Dano (Só toma dano se não estiver invulnerável nem rolando)
if (!is_invulnerable && state != player_state.roll) {
    
    // 1. Dano do Projétil de Ácido da Centopeia
    var gota_acido = instance_place(x, y, obj_acido_centopeia);
    if (gota_acido != noone) {
        hp -= gota_acido.dano;
        is_invulnerable = true;
        iframe_timer = 45;
        
        var dir_acido = sign(gota_acido.hspd);
        if (dir_acido == 0) dir_acido = -facing;
        
        hspd = dir_acido * 4;
        vspd = -3;
        state = player_state.air;
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.hitstop_timer = 4;
            obj_game_controller.shake_magnitude = 3;
        }
        
        instance_destroy(gota_acido);
    }
    
    // 2. Dano de Espinhos
    if (place_meeting(x, y, obj_espinho)) {
        hp -= 20; 
        is_invulnerable = true; 
        iframe_timer = 60; 
        vspd = -4; 
        hspd = -facing * 5; 
        state = player_state.air; 
    }
    
    // 3. Dano do Chefe: Centopeia Alfa
    var boss = instance_place(x, y, obj_boss_centopeia);
    if (boss != noone) {
        if (boss.state != centopeia_state.subterranea && boss.state != centopeia_state.emergindo) {
            var dano_boss = (boss.state == centopeia_state.investida) ? 35 : 20;
            hp -= dano_boss;
            
            is_invulnerable = true;
            iframe_timer = 60;
            
            var dir_empurrao = sign(x - boss.x);
            if (dir_empurrao == 0) dir_empurrao = -facing;
            
            hspd = dir_empurrao * 7;
            vspd = -5;
            state = player_state.air;
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 8;
                obj_game_controller.shake_magnitude = 6;
            }
            
            show_debug_message("DANO DO CHEFE! HP Restante: " + string(hp));
        }
    }
    
    // 4. Dano de Inimigos Comuns (Besouro / Vespa)
    var inimigo = instance_place(x, y, obj_enemy);
    if (inimigo != noone && inimigo != boss) {
        hp -= 15;
        is_invulnerable = true;
        iframe_timer = 45;
        
        var dir_hit = sign(x - inimigo.x);
        if (dir_hit == 0) dir_hit = -facing;
        
        hspd = dir_hit * 5;
        vspd = -4;
        state = player_state.air;
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.hitstop_timer = 5;
            obj_game_controller.shake_magnitude = 3;
        }
    }
}

// Controle de Morte do Rato na Simulação
if (hp <= 0) {
    hp = 0;
    show_debug_message("VOCE MORREU! Reiniciando batalha...");
    room_restart();
}

// =====================================================================
// 5. APLICAÇÃO FÍSICA DE MOVIMENTO E COLISÕES
// =====================================================================

// Colisão Horizontal
if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) { 
        x += sign(hspd); 
    }
    hspd = 0;
}
x += hspd;

// Colisão Vertical (Geral para fora do estado air)
if (state != player_state.air) {
    if (place_meeting(x, y + vspd, obj_colisor)) {
        while (!place_meeting(x, y + sign(vspd), obj_colisor)) { 
            y += sign(vspd); 
        }
        vspd = 0;
    }
}
y += vspd;

// Gerar sucata de teste
if (keyboard_check_pressed(ord("U"))) { 
    repeat(3) { instance_create_layer(x, y - 10, "Instances", obj_scrap); } 
}

// Squash & Stretch
scale_x = lerp(scale_x, 1.0, 0.15);
scale_y = lerp(scale_y, 1.0, 0.15);