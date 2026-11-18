if (layer == -1 && layer_exists("Instances")) layer = layer_get_id("Instances");
sprite_index = spr_boss_centopeia_box;
mask_index   = spr_boss_centopeia_box;
// ==========================================
// 0. SISTEMA DE HITSTOP E INICIALIZAÇÃO SEGURA
// ==========================================
if (!variable_instance_exists(id, "usando_mordida"))        usando_mordida = false;
if (!variable_instance_exists(id, "mordida_hitbox_ativa")) mordida_hitbox_ativa = false;
if (!variable_instance_exists(id, "morrendo"))               morrendo = false;
if (!variable_instance_exists(id, "escala_boss"))          escala_boss = 1.0;
if (!variable_instance_exists(id, "facing"))               facing = -1;

var sprite_dir = 1; 

if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
}

// ==========================================
// 0.5 ESTADO DE MORTE COM ANIMAÇÃO (spr_boss_centopeia_death)
// ==========================================
if (hp <= 0) {
    hp = 0;
    hspd = 0;
    vspd += grv;
    if (place_meeting(x, y + vspd, obj_colisor)) {
        while (!place_meeting(x, y + sign(vspd), obj_colisor)) y += sign(vspd);
        vspd = 0;
    }
    y += vspd;

    if (facing != 0) image_xscale = facing * sprite_dir * escala_boss;
    image_yscale = escala_boss;

    if (!morrendo) {
        morrendo = true;
        sprite_index = spr_boss_centopeia_death;
        image_index = 0;
        image_speed = 0.85;
        image_blend = c_white;
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.hitstop_timer = 20;
            obj_game_controller.shake_magnitude = 10;
        }
    } else {
        sprite_index = spr_boss_centopeia_death;
        image_speed = 0.85;
        if (image_index >= image_number - 1) {
            show_debug_message("CHEFE DERROTADO! A floresta esta livre!");
            repeat(8) {
                instance_create_layer(x + irandom_range(-20, 20), y - 12, layer, obj_scrap);
            }
            if (object_exists(obj_item_drop)) {
                for (var i = 0; i < 3; i++) {
                    var _d = instance_create_layer(x + (i * 12) - 12, y - 16, layer, obj_item_drop);
                    _d.tipo_item = i;
                }
            }
            if (instance_exists(obj_player)) {
                obj_player.arma_xp += 50;
            }
            instance_destroy();
        }
    }
    exit;
}

if (piscar > 0) piscar--;

if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

if (piscar == 9 && state != centopeia_state.emergindo) {
    vspd = 0;
    hspd *= 0.2;
}

image_blend = (queimando_timer > 0) ? c_orange : c_white;

var dir_to_player = 0;
if (instance_exists(obj_player)) {
    dir_to_player = sign(obj_player.x - x);
}

// ==========================================
// 1. MÁQUINA DE ESTADOS DA CENTOPEIA
// ==========================================
switch (state) {
    
    // --- ESTADO 1: SUBTERRÂNEA ---
    case centopeia_state.subterranea:
        hspd = 0;
        vspd = 0;
        usando_mordida = false;
        mordida_hitbox_ativa = false;
        
        sprite_index = spr_boss_centopeia_submerge;
        image_index = image_number - 1;
        image_speed = 0;
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist < 220) {
                alvo_x = obj_player.x;
                alvo_y = obj_player.y;
                
                var _chao = 0;
                while (!place_meeting(alvo_x, alvo_y + 1, obj_colisor) && _chao < 200) {
                    alvo_y += 2;
                    _chao++;
                }
                
                x = alvo_x;
                y = alvo_y;
                var seguranca = 0;
                while (place_meeting(x, y, obj_colisor) && seguranca < 64) {
                    y -= 1;
                    seguranca++;
                }
                
                if (dir_to_player != 0) facing = dir_to_player;
                sprite_index = spr_boss_centopeia_emerge;
                image_index = 0;
                image_speed = 0.65;
                
                state = centopeia_state.emergindo;
                action_timer = 36; 
                
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_magnitude = 2;
                }
            }
        }
        break;
        
    // --- ESTADO 2: EMERGINDO ---
    case centopeia_state.emergindo:
        hspd = 0;
        vspd = 0;
        sprite_index = spr_boss_centopeia_emerge;
        image_speed = 0.85;
        
        // Nos primeiros 14 frames (timer 36 até 23), é apenas o aviso da terra tremendo (sem dano!)
        if (action_timer > 24 && dir_to_player != 0) {
            facing = dir_to_player;
        }
        
        if (image_index >= image_number - 1) {
            image_index = image_number - 1;
            image_speed = 0;
        }
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.shake_magnitude = max(obj_game_controller.shake_magnitude, 1.5);
        }
        
        action_timer--;
        
        // EXATAMENTE NO FRAME 22: Ela rompe o chão e gera a Hitbox por 4 frames!
        if (action_timer == 22) {
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 6;
                obj_game_controller.shake_magnitude = 7;
            }
            if (object_exists(obj_hitbox_enemy)) {
                var hit = instance_create_layer(x, y - 16, layer, obj_hitbox_enemy);
                hit.image_xscale = 1.6;
                hit.image_yscale = 1.6;
                hit.duracao = 4;
                hit.dano = 20;
            }
        }
        
        if (action_timer <= 0) {
            if (dir_to_player != 0) facing = dir_to_player;
            state = centopeia_state.patrulha_luta;
            action_timer = 55; 
            sprite_index = spr_boss_centopeia_idle;
            image_index = 0;
            image_speed = 1;
        }
        break;
        
    // --- ESTADO 3: PATRULHA E ESCOLHA INTELIGENTE ---
    case centopeia_state.patrulha_luta:
        usando_mordida = false;
        mordida_hitbox_ativa = false;
        vspd += grv;
        
        if (sprite_index != spr_boss_centopeia_idle) {
            sprite_index = spr_boss_centopeia_idle;
            image_index = 0;
        }
        image_speed = 1;
        
        if (instance_exists(obj_player)) {
            if (dir_to_player != 0) facing = dir_to_player;
            
            var dist_p = abs(obj_player.x - x);
            
            if (dist_p < 75) {
                hspd = facing * 0.8;
                if (action_timer > 18) action_timer = 18;
            } else {
                hspd = facing * 1.8;
            }
            
            action_timer--;
            if (action_timer <= 0) {
                if (dir_to_player != 0) facing = dir_to_player;
                
                if (dist_p < 95) {
                    var _escolha_curta = choose("mordida", "mordida", "mordida", "investida");
                    if (_escolha_curta == "mordida") {
                        usando_mordida = true;
                        state = centopeia_state.preparando_bote;
                        action_timer = 36; 
                        sprite_index = spr_boss_centopeia_bite;
                        image_index = 0;
                    } else {
                        usando_mordida = false;
                        state = centopeia_state.preparando_bote;
                        action_timer = 20;
                        sprite_index = spr_boss_centopeia_dash;
                        image_index = 0;
                    }
                }
                else if (dist_p < 160) {
                    var _escolha_media = choose("investida", "investida", "mordida", "cavando");
                    if (_escolha_media == "mordida") {
                        usando_mordida = true;
                        state = centopeia_state.preparando_bote;
                        action_timer = 36;
                        sprite_index = spr_boss_centopeia_bite;
                        image_index = 0;
                    } else if (_escolha_media == "investida") {
                        usando_mordida = false;
                        state = centopeia_state.preparando_bote;
                        action_timer = 20;
                        sprite_index = spr_boss_centopeia_dash;
                        image_index = 0;
                    } else {
                        state = centopeia_state.cavando;
                        action_timer = 32;
                        sprite_index = spr_boss_centopeia_submerge;
                        image_index = 0;
                    }
                }
                else {
                    var proximo_ataque = choose(
                        centopeia_state.cuspindo,
                        centopeia_state.cuspindo,
                        centopeia_state.preparando_bote,
                        centopeia_state.cavando
                    );
                    usando_mordida = false;
                    state = proximo_ataque;
                    
                    if (proximo_ataque == centopeia_state.preparando_bote) {
                        action_timer = 20;
                        sprite_index = spr_boss_centopeia_dash;
                        image_index = 0;
                    } else if (proximo_ataque == centopeia_state.cuspindo) {
                        action_timer = 60;
                        sprite_index = spr_boss_centopeia_bite;
                        image_index = 0;
                    } else {
                        action_timer = 32;
                        sprite_index = spr_boss_centopeia_submerge;
                        image_index = 0;
                    }
                }
            }
        }
        break;
        
    // --- ESTADO 3.5: PREPARANDO BOTE OU EXECUTANDO MORDIDA ---
    case centopeia_state.preparando_bote:
        vspd += grv;
        
        if (usando_mordida) {
            sprite_index = spr_boss_centopeia_bite;
            mordida_hitbox_ativa = false;
            
            if (action_timer > 16) {
                if (dir_to_player != 0) facing = dir_to_player;
                hspd = -facing * 0.5;
                image_speed = 0.6;
                if (image_index >= 2.9) {
                    image_index = 2.9;
                    image_speed = 0;
                }
            }
            else if (action_timer == 16) {
                hspd = facing * 6.5;
                image_index = 3;
                image_speed = 1.2;
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_magnitude = 3;
                }
            }
            else if (action_timer >= 9 && action_timer < 16) {
                mordida_hitbox_ativa = true;
                hspd = lerp(hspd, 0, 0.25);
                image_speed = 1.1;
                
                if (object_exists(obj_hitbox_enemy)) {
                    var hit = instance_create_layer(x + (facing * 28), y - 10, layer, obj_hitbox_enemy);
                    hit.image_xscale = facing * 1.5;
                    hit.duracao = 2;
                    hit.dano = 20;
                }
            }
            else {
                mordida_hitbox_ativa = false;
                hspd = lerp(hspd, 0, 0.3);
                if (image_index >= image_number - 1) {
                    image_index = image_number - 1;
                    image_speed = 0;
                }
            }
            
            action_timer--;
            if (action_timer <= 0) {
                usando_mordida = false;
                mordida_hitbox_ativa = false;
                state = centopeia_state.recuperando;
                action_timer = 35;
            }
        }
        else {
            if (dir_to_player != 0) facing = dir_to_player;
            
            sprite_index = spr_boss_centopeia_dash;
            image_speed = 0.7;
            if (image_index >= 2) {
                image_index = 2;
                image_speed = 0;
            }
            hspd = -facing * 0.8;
            
            action_timer--;
            if (action_timer <= 0) {
                state = centopeia_state.investida;
                action_timer = 28;
                image_index = 2;
                image_speed = 1.2;
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_magnitude = 3;
                }
            }
        }
        break;

    // --- ESTADO 4: INVESTIDA FEROZ COM OBJ_HITBOX_ENEMY ---
    case centopeia_state.investida:
        sprite_index = spr_boss_centopeia_dash;
        image_speed = 1.2;
        hspd = facing * 5.8; 
        vspd += grv;
        
        if (object_exists(obj_hitbox_enemy)) {
            var hit = instance_create_layer(x + (facing * 22), y - 10, layer, obj_hitbox_enemy);
            hit.image_xscale = facing * 1.8;
            hit.duracao = 2;
            hit.dano = 25;
        }
        
        if (place_meeting(x + hspd, y, obj_colisor)) {
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 6;
            }
            hspd = -facing * 2;
            vspd = -3;
            state = centopeia_state.recuperando;
            action_timer = 55; 
            break;
        }
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.recuperando;
            action_timer = 45; 
        }
        break;

    // --- ESTADO 4.5: RECUPERANDO O FÔLEGO ---
    case centopeia_state.recuperando:
        if (sprite_index != spr_boss_centopeia_idle) {
            sprite_index = spr_boss_centopeia_idle;
            image_index = 0;
        }
        image_speed = 0.8;
        hspd = lerp(hspd, 0, 0.15); 
        vspd += grv;
        image_blend = c_ltgray; 
        usando_mordida = false;
        mordida_hitbox_ativa = false;
        
        action_timer--;
        if (action_timer <= 0) {
            if (dir_to_player != 0) facing = dir_to_player;
            image_blend = c_white;
            state = centopeia_state.patrulha_luta;
            action_timer = 55;
        }
        break;

    // --- ESTADO 5: CUSPINDO ÁCIDO ---
    case centopeia_state.cuspindo:
        sprite_index = spr_boss_centopeia_bite;
        image_speed = 0.9;
        hspd = 0;
        vspd += grv;
        
        if (action_timer > 45 && dir_to_player != 0) {
            facing = dir_to_player;
        }
        
        action_timer--;
        
        if ((action_timer == 42 || action_timer == 26 || action_timer == 10) && object_exists(obj_acido_centopeia)) {
            image_index = 2; 
            var tiro = instance_create_layer(x + (facing * 20), y - 24, layer, obj_acido_centopeia);
            var dist_x = instance_exists(obj_player) ? abs(obj_player.x - x) : 120;
            var forca_h = clamp(dist_x / 35, 3, 7) + random_range(-0.8, 0.8);
            
            tiro.hspd = facing * forca_h;
            tiro.vspd = random_range(-6.5, -4.5);
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 2;
            }
        }
        
        if (action_timer <= 0) {
            state = centopeia_state.recuperando;
            action_timer = 25;
        }
        break;
        
    // --- ESTADO 6: CAVANDO ---
    case centopeia_state.cavando:
        hspd = 0;
        vspd = 0; 
        sprite_index = spr_boss_centopeia_submerge;
        image_speed = 0.85;
        
        if (image_index >= image_number - 1) {
            image_index = image_number - 1;
            image_speed = 0;
        }
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.subterranea;
        }
        break;
}

// ==========================================
// 1.5 ALINHAMENTO AUTOMÁTICO DA SPRITE
// ==========================================
if (facing != 0) {
    image_xscale = facing * sprite_dir * escala_boss;
}
image_yscale = escala_boss;

// ==========================================
// 2. COLISÕES FÍSICAS
// ==========================================
if (state != centopeia_state.cavando && state != centopeia_state.subterranea && state != centopeia_state.emergindo) {
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
}