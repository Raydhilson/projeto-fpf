// ==========================================

// 0. SISTEMA DE HITSTOP (PAUSA O RATO)

// ==========================================

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

if (move_dir != 0) { facing = move_dir; }



var key_jump          = keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1);

var key_jump_released = keyboard_check_released(vk_space) || gamepad_button_check_released(0, gp_face1); 

var key_attack        = keyboard_check_pressed(ord("J"))  || gamepad_button_check_pressed(0, gp_face3); 

var key_roll          = keyboard_check_pressed(ord("K"))  || gamepad_button_check_pressed(0, gp_face2); 

var key_throw         = keyboard_check_pressed(ord("F"))  || gamepad_button_check_pressed(0, gp_shoulderr);



// Abre o Menu com o Start no comando ou ESC no teclado
// Hub do Personagem (Inventário/Maestria) no I ou Select do comando
var key_menu = keyboard_check_pressed(ord("I")) || gamepad_button_check_pressed(0, gp_select);

var key_heal    = keyboard_check_pressed(ord("Q")) || gamepad_button_check_pressed(0, gp_padl);

var key_up      = keyboard_check_pressed(vk_up)    || gamepad_button_check_pressed(0, gp_padu);

var key_down    = keyboard_check_pressed(vk_down)  || gamepad_button_check_pressed(0, gp_padd);

var key_confirm = keyboard_check_pressed(vk_enter) || gamepad_button_check_pressed(0, gp_face1);

// Teclas de Aba (LB / RB ou Q / E)
var key_tab_left  = keyboard_check_pressed(ord("Q")) || gamepad_button_check_pressed(0, gp_shoulderl);
var key_tab_right = keyboard_check_pressed(ord("E")) || gamepad_button_check_pressed(0, gp_shoulderr);

// =====================================================================

// 2. USO DE ITENS (CURATIVO) E TIMERS FÍSICOS

// =====================================================================

if (key_heal && curativo_count > 0 && hp < hp_max) {

    curativo_count--;

    hp = min(hp + 30, hp_max);

    show_debug_message("Curou! HP atual: " + string(hp));

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

        sprite_index = spr_player;

        

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

            combo_count = 1;       // Inicia o combo!

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

        }

        break;

        

    // --- CORRENDO ---

    case player_state.run:

        hspd = lerp(hspd, move_dir * walk_sp, accel); 

        image_blend = c_blue;

        

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

            combo_count = 1;       // Inicia o combo!

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

        }

        break;

        

    // --- NO AR ---

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

            ataque_buffer = false;

        }

        

        var taxa_lerp = (move_dir != 0) ? accel : fric;

        hspd = lerp(hspd, move_dir * walk_sp, taxa_lerp);

        

        vspd += grv;

        if (vspd > max_vspd) vspd = max_vspd;

        

        if (key_jump_released && vspd < 0) { vspd *= 0.45; }

        

        image_blend = c_yellow;

        

        if (place_meeting(x, y + vspd, obj_colisor)) {

            while (!place_meeting(x, y + sign(vspd), obj_colisor)) { y += sign(vspd); }

            vspd = 0; scale_x = 1.35; scale_y = 0.75; 

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

        

        // Cor muda para vermelho escuro se for o Combo 2

        image_blend = (combo_count == 1) ? c_red : c_maroon; 

        

        // BUFFER DE COMBO: Se apertar de novo e tiver maestria 2

        if (key_attack && arma_nivel >= 2) {

            ataque_buffer = true; 

        }

        

        // CRIA A HITBOX (Frame 10 da animação)

        if (action_timer == 10) {

            var hit = instance_create_layer(x + (facing * 16), y - 10, "Instances", obj_hitbox);

            hit.image_xscale = facing;

            

            // SE FOR O GOLPE 2, BUFFA O DANO E O ALCANCE!

            if (combo_count == 2) {

                hit.dano = 2; 

                hit.image_xscale = facing * 1.5; 

            }

        }



        action_timer--;

        

        if (action_timer <= 0) {

            // DECISÃO: Vai pro Combo 2 ou volta ao normal?

            if (ataque_buffer && combo_count == 1 && arma_nivel >= 2) {

                combo_count = 2;

                action_timer = 15; // Reinicia pra segunda animação

                ataque_buffer = false;

                hspd = facing * 4; // Passo bruto pra frente

            } else {

                // Fim do ataque

                combo_count = 0;

                sprite_index = spr_player;

                if (place_meeting(x, y + 1, obj_colisor)) {

                    state = (move_dir != 0) ? player_state.run : player_state.idle;

                } else {

                    state = player_state.air;

                }

            }

        }

        break;



    // --- ROLANDO ---

    case player_state.roll:

        hspd = facing * roll_sp; 

        vspd = 0; image_blend = c_green;

        

        action_timer--;

        if (action_timer <= 0) { state = (move_dir != 0) ? player_state.run : player_state.idle; }

        break;



    // --- ESCORREGANDO NA PAREDE ---

    case player_state.wall_slide:

        vspd = 2; image_blend = c_orange;

        var wall_dir = place_meeting(x + 1, y, obj_colisor) ? 1 : -1;

        

        if (key_jump) {

            vspd = wall_jump_vspd; hspd = -wall_dir * wall_jump_hspd; facing = -wall_dir;

            scale_x = 0.75; scale_y = 1.35; state = player_state.air;

        }

        

        if (move_dir != wall_dir || !place_meeting(x + wall_dir, y, obj_colisor) || place_meeting(x, y + 1, obj_colisor)) {

            state = player_state.air;

        }

        break;



    // --- MENU DE CRAFT ---

    // --- HUB DO PERSONAGEM (MENU EM ABAS) ---
    case player_state.menu:
        hspd = 0; vspd = 0; // Congela o rato
        
        // 1. Trocar de Abas (Navegação em Loop)
        if (key_tab_right) {
            aba_atual++;
            if (aba_atual > 2) aba_atual = 0;
        }
        if (key_tab_left) {
            aba_atual--;
            if (aba_atual < 0) aba_atual = 2;
        }
        
        // 2. Lógica Específica da Aba de CRAFTING (Aba 1)
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
                    state = player_state.craft; // Sai do menu e vai fabricar
                }
            }
        }
        break;



    // --- FABRICANDO ITEM ---

    case player_state.craft:

        hspd = 0; vspd = 0; image_blend = c_purple; 

        craft_timer++; 

        if (craft_timer >= craft_time_max) {

            if (craft_selected_item == 0) { curativo_count++; show_debug_message("Curativo feito!"); }

            else if (craft_selected_item == 1) { molotov_count++; show_debug_message("Molotov feito!"); }

            craft_timer = 0; state = player_state.idle; 

        }

        break;

}



// =====================================================================

// 4. SISTEMAS GERAIS: I-FRAMES, DANO E COLISÕES

// =====================================================================

if (is_invulnerable) {

    iframe_timer--;

    if (iframe_timer <= 0) is_invulnerable = false;

}



// Tomando Dano do Espinho

if (!is_invulnerable) {

    if (place_meeting(x, y, obj_espinho)) {

        hp -= 20; is_invulnerable = true; iframe_timer = 60; 

        vspd = -4; hspd = -facing * 5; state = player_state.air; 

    }

}



// Colisão Horizontal

if (place_meeting(x + hspd, y, obj_colisor)) {

    while (!place_meeting(x + sign(hspd), y, obj_colisor)) { x += sign(hspd); }

    hspd = 0;

}

x += hspd;



// Colisão Vertical

if (state != player_state.air) {

    if (place_meeting(x, y + vspd, obj_colisor)) {

        while (!place_meeting(x, y + sign(vspd), obj_colisor)) { y += sign(vspd); }

        vspd = 0;

    }

}

y += vspd;



// Gerar sucata de teste

if (keyboard_check_pressed(ord("U"))) { repeat(3) { instance_create_layer(x, y - 10, "Instances", obj_scrap); } }



// Squash & Stretch

scale_x = lerp(scale_x, 1.0, 0.15);

scale_y = lerp(scale_y, 1.0, 0.15);