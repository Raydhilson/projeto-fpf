// ==========================================
// 0. SISTEMA DE HITSTOP E INICIALIZAÇÃO SEGURA DA MORDIDA
// ==========================================
if (!variable_instance_exists(id, "usando_mordida"))       usando_mordida = false;
if (!variable_instance_exists(id, "mordida_hitbox_ativa")) mordida_hitbox_ativa = false;

if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

// Super Armor
if (piscar == 9 && state != centopeia_state.emergindo) {
    vspd = 0;
    hspd *= 0.2;
}

// Localiza o jogador de pé mais próximo na arena (Ignora quem está nocauteado / downed!)
var alvo = noone;
var menor_dist = 999999;
with (obj_player) {
    if (state != player_state.downed) {
        var _d = point_distance(x, y, other.x, other.y);
        if (_d < menor_dist) {
            menor_dist = _d;
            alvo = id;
        }
    }
}

// ==========================================
// 1. MÁQUINA DE ESTADOS DA CENTOPEIA
// ==========================================
switch (state) {
    
    // --- ESTADO 1: SUBTERRÂNEA (ESCONDIDA) ---
    case centopeia_state.subterranea:
        hspd = 0;
        vspd = 0;
        usando_mordida = false;
        mordida_hitbox_ativa = false;
        image_blend = c_dkgray; 
        
        if (alvo != noone) {
            var dist = point_distance(x, y, alvo.x, alvo.y);
            if (dist < 220) {
                alvo_x = alvo.x;
                alvo_y = alvo.y;
                
                var _chao = 0;
                while (!place_meeting(alvo_x, alvo_y + 1, obj_colisor) && _chao < 200) {
                    alvo_y += 2;
                    _chao++;
                }
                
                state = centopeia_state.emergindo;
                action_timer = 45; 
                
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_magnitude = 2;
                }
            }
        }
        break;
        
    // --- ESTADO 2: EMERGINDO (O BOTE SURPRESA) ---
    case centopeia_state.emergindo:
        hspd = 0;
        vspd = 0;
        image_blend = c_orange; 
        
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.shake_magnitude = max(obj_game_controller.shake_magnitude, 1.5);
        }
        
        action_timer--;
        if (action_timer <= 0) {
            x = alvo_x;
            y = alvo_y - 24;
            
            var seguranca = 0;
            while (place_meeting(x, y, obj_colisor) && seguranca < 64) {
                y -= 2;
                seguranca++;
            }
            
            vspd = -6; 
            state = centopeia_state.patrulha_luta;
            action_timer = 55;
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 10;
                obj_game_controller.shake_magnitude = 8;
            }
        }
        break;
        
    // --- ESTADO 3: PATRULHA E ESCOLHA INTELIGENTE POR DISTÂNCIA ---
    case centopeia_state.patrulha_luta:
        image_blend = c_red; 
        usando_mordida = false;
        mordida_hitbox_ativa = false;
        vspd += grv;
        
        if (alvo != noone) {
            var dir = sign(alvo.x - x);
            if (dir != 0) facing = dir;
            
            var dist_p = abs(alvo.x - x);
            
            if (dist_p < 75) {
                hspd = facing * 0.8;
                if (action_timer > 18) action_timer = 18;
            } else {
                hspd = facing * 1.8;
            }
            
            action_timer--;
            if (action_timer <= 0) {
                if (dir != 0) facing = dir;
                
                // CURTA DISTÂNCIA (< 95px): Prioriza a MORDIDA FRONTAL!
                if (dist_p < 95) {
                    var _escolha_curta = choose("mordida", "mordida", "mordida", "investida");
                    if (_escolha_curta == "mordida") {
                        usando_mordida = true;
                        state = centopeia_state.preparando_bote;
                        action_timer = 36;
                    } else {
                        usando_mordida = false;
                        state = centopeia_state.preparando_bote;
                        action_timer = 22;
                    }
                }
                // MÉDIA DISTÂNCIA (95px a 160px)
                else if (dist_p < 160) {
                    var _escolha_media = choose("investida", "investida", "mordida", "cavando");
                    if (_escolha_media == "mordida") {
                        usando_mordida = true;
                        state = centopeia_state.preparando_bote;
                        action_timer = 36;
                    } else if (_escolha_media == "investida") {
                        usando_mordida = false;
                        state = centopeia_state.preparando_bote;
                        action_timer = 22;
                    } else {
                        state = centopeia_state.cavando;
                        action_timer = 30;
                    }
                }
                // LONGA DISTÂNCIA (> 160px)
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
                        action_timer = 22;
                    } else if (proximo_ataque == centopeia_state.cuspindo) {
                        action_timer = 60;
                    } else {
                        action_timer = 30;
                    }
                }
            }
        }
        break;
        
    // --- ESTADO 3.5: PREPARANDO BOTE OU EXECUTANDO MORDIDA FRONTAL ---
    case centopeia_state.preparando_bote:
        vspd += grv;
        
        if (usando_mordida) {
            mordida_hitbox_ativa = false;
            
            if (action_timer > 16) {
                hspd = -facing * 0.5;
                image_blend = ((action_timer div 3) mod 2 == 0) ? c_yellow : c_orange;
            }
            else if (action_timer == 16) {
                hspd = facing * 6.5;
                image_blend = c_white;
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_magnitude = 3;
                }
            }
            else if (action_timer >= 9 && action_timer < 16) {
                mordida_hitbox_ativa = true;
                hspd = lerp(hspd, 0, 0.25);
                image_blend = c_fuchsia;
                
                var alcance_mordida = 42;
                var x1 = (facing == 1) ? bbox_right : (bbox_left - alcance_mordida);
                var x2 = (facing == 1) ? (bbox_right + alcance_mordida) : bbox_left;
                var y1 = bbox_top - 6;
                var y2 = bbox_bottom;
                
                // Verifica colisão da mordida contra todos os jogadores de pé (P1 e P2)!
                var _facing_boss = facing;
                with (obj_player) {
                    if (collision_rectangle(x1, y1, x2, y2, id, false, true)) {
                        if (!is_invulnerable && state != player_state.roll && state != player_state.downed) {
                            hp -= 20;
                            is_invulnerable = true;
                            iframe_timer = 60;
                            hspd = _facing_boss * 6.5;
                            vspd = -4.5;
                            state = player_state.air;
                            
                            if (instance_exists(obj_game_controller)) {
                                obj_game_controller.hitstop_timer = 5;
                                obj_game_controller.shake_magnitude = 4;
                            }
                        }
                    }
                }
            }
            else {
                mordida_hitbox_ativa = false;
                hspd = lerp(hspd, 0, 0.3);
                image_blend = c_red;
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
            hspd = -facing * 0.8;
            image_blend = ((action_timer div 3) mod 2 == 0) ? c_yellow : c_orange;
            
            action_timer--;
            if (action_timer <= 0) {
                state = centopeia_state.investida;
                action_timer = 28;
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_magnitude = 3;
                }
            }
        }
        break;

    // --- ESTADO 4: INVESTIDA FEROZ ---
    case centopeia_state.investida:
        hspd = facing * 5.8; 
        vspd += grv;
        image_blend = c_fuchsia; 
        
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
        hspd = lerp(hspd, 0, 0.15); 
        vspd += grv;
        image_blend = c_gray; 
        usando_mordida = false;
        mordida_hitbox_ativa = false;
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.patrulha_luta;
            action_timer = 55;
        }
        break;

    // --- ESTADO 5: CUSPINDO ÁCIDO ---
    case centopeia_state.cuspindo:
        hspd = 0;
        vspd += grv;
        image_blend = c_lime;
        
        action_timer--;
        
        if ((action_timer == 42 || action_timer == 26 || action_timer == 10) && object_exists(obj_acido_centopeia)) {
            var tiro = instance_create_layer(x + (facing * 20), y - 16, layer, obj_acido_centopeia);
            var dist_x = (alvo != noone) ? abs(alvo.x - x) : 120;
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
        vspd = 1.5;
        image_blend = c_dkgray;
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.subterranea;
        }
        break;
}

if (facing != 0) {
    image_xscale = facing;
}

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
} else if (state == centopeia_state.cavando) {
    y += vspd;
}

// ==========================================
// 3. MORTE DO CHEFE (VITÓRIA DA DEMO!)
// ==========================================
if (hp <= 0) {
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 30;
        obj_game_controller.shake_magnitude = 10;
    }
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
    
    with (obj_player) {
        arma_xp += 50;
    }
    
    instance_destroy();
}