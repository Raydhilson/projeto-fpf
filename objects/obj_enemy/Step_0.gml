// ==========================================

// 0. SISTEMA DE HITSTOP (PAUSA O INIMIGO)

// ==========================================

if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {

    image_speed = 0;

    exit; // Corta a leitura de física/movimento neste frame!

} else {

    image_speed = 1;

}



// ==========================================

// 1. GRAVIDADE E TIMERS

// ==========================================

vspd += grv;

if (piscar > 0) piscar--;



// ==========================================

// 2. MÁQUINA DE ESTADOS DA IA

// ==========================================

switch (state) {

    

    // --- ESTADO 1: PATRULHA ---

    case enemy_state.patrol:

        // Só se move se não estiver tomando knockback

        if (piscar <= 0) {

            hspd = lerp(hspd, walk_spd * facing, 0.1);

        }

        image_blend = c_white; 

        

        var hit_wall = place_meeting(x + facing, y, obj_colisor);

        var no_ledge = !place_meeting(x + (15 * facing), y + 1, obj_colisor); 

        

        // Se bater na parede ou o chão acabar, e NÃO estiver voando de knockback

        if ((hit_wall || no_ledge) && place_meeting(x, y+1, obj_colisor)) {

            facing = -facing; 

        }

        

        if (instance_exists(obj_player)) {

            var dist = point_distance(x, y, obj_player.x, obj_player.y);

            if (dist <= vision_range) {

                state = enemy_state.chase; 

            }

        }

        break;

        

    // --- ESTADO 2: PERSEGUIÇÃO ---

    case enemy_state.chase:

        image_blend = c_red; 

        

        if (instance_exists(obj_player)) {

            var dist = point_distance(x, y, obj_player.x, obj_player.y);

            

            var dir_to_player = sign(obj_player.x - x);

            if (dir_to_player != 0 && piscar <= 0) {

                facing = dir_to_player;

            }

            

            // Só avança se não estiver tomando knockback

            if (piscar <= 0) {

                hspd = lerp(hspd, chase_spd * facing, 0.1);

            }

            

            if (dist > lose_interest_range) {

                state = enemy_state.patrol;

            }

        } else {

            state = enemy_state.patrol;

        }

        break;

}



// Vira a imagem do inimigo

if (facing != 0) {

    image_xscale = facing;

}



// ==========================================

// 3. COLISÕES FÍSICAS

// ==========================================

// Horizontal

if (place_meeting(x + hspd, y, obj_colisor)) {

    while (!place_meeting(x + sign(hspd), y, obj_colisor)) {

        x += sign(hspd);

    }

    hspd = 0;

}

x += hspd;



// Vertical

if (place_meeting(x, y + vspd, obj_colisor)) {

    while (!place_meeting(x, y + sign(vspd), obj_colisor)) {

        y += sign(vspd);

    }

    vspd = 0;

}

y += vspd;



// ==========================================

// 4. MORTE E SISTEMA DE XP

// ==========================================

if (hp <= 0) {

    if (instance_exists(obj_player)) {

        obj_player.arma_xp += 5; // Cada inimigo dá 5 de XP

        show_debug_message("Ganhou 5 XP! Total: " + string(obj_player.arma_xp));

        

        // Verifica o Level Up da Lança

        if (obj_player.arma_xp >= obj_player.arma_xp_max && obj_player.arma_nivel == 1) {

            obj_player.arma_nivel = 2; // Sobe pro nível 2

            show_debug_message("LEVEL UP! Lança nivel 2! Combo Duplo Liberado!");

        }

    }

    

    // Opcional: Criar partículas aqui no futuro

    instance_destroy();

}