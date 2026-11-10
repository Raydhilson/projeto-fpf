// ==========================================
// 0. SISTEMA DE HITSTOP (PAUSA O CHEFE)
// ==========================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

// Dano de queimadura se a lança estiver em chamas
if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

// Super Armor: impede que a estocada do rato jogue o chefe para o alto
if (piscar == 9 && state != centopeia_state.emergindo) {
    vspd = 0;
    hspd *= 0.2;
}

// ==========================================
// 1. MÁQUINA DE ESTADOS DA CENTOPEIA
// ==========================================
switch (state) {
    
    // --- ESTADO 1: SUBTERRÂNEA (ESCONDIDA) ---
    case centopeia_state.subterranea:
        hspd = 0;
        vspd = 0;
        image_blend = c_dkgray; 
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist < 220) {
                alvo_x = obj_player.x;
                alvo_y = obj_player.y;
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
            
            // Segurança anti-travamento em paredes
            var seguranca = 0;
            while (place_meeting(x, y, obj_colisor) && seguranca < 64) {
                y -= 2;
                seguranca++;
            }
            
            vspd = -6; 
            state = centopeia_state.patrulha_luta;
            action_timer = 80; // Tempo até o primeiro ataque após emergir
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 10;
                obj_game_controller.shake_magnitude = 8;
            }
        }
        break;
        
    // --- ESTADO 3: PATRULHA E ESCOLHA INTELIGENTE POR DISTÂNCIA ---
    case centopeia_state.patrulha_luta:
        image_blend = c_red; 
        vspd += grv;
        
        if (instance_exists(obj_player)) {
            var dir = sign(obj_player.x - x);
            if (dir != 0) facing = dir;
            
            hspd = facing * 1.8; // Levemente mais cadenciada na caminhada
            
            action_timer--;
            if (action_timer <= 0) {
                var dist_p = abs(obj_player.x - x);
                var proximo_ataque;
                
                // IA por Distância: Perto prioriza bote; Longe prioriza ácido ou cavar
                if (dist_p < 120) {
                    proximo_ataque = choose(
                        centopeia_state.preparando_bote,
                        centopeia_state.preparando_bote,
                        centopeia_state.cavando
                    );
                } else {
                    proximo_ataque = choose(
                        centopeia_state.cuspindo,
                        centopeia_state.cuspindo,
                        centopeia_state.preparando_bote,
                        centopeia_state.cavando
                    );
                }
                
                // Trava a direção para onde o player está AGORA (permite rolar para as costas!)
                if (dir != 0) facing = dir;
                state = proximo_ataque;
                
                if (proximo_ataque == centopeia_state.preparando_bote) {
                    action_timer = 22; // 22 frames de aviso antes de correr!
                } else if (proximo_ataque == centopeia_state.cuspindo) {
                    action_timer = 60;
                } else {
                    action_timer = 30;
                }
            }
        }
        break;
        
    // --- ESTADO 3.5: PREPARANDO BOTE (AVISO / TELEGRAPH) ---
    case centopeia_state.preparando_bote:
        // Dá uma leve recuada para trás preparando o bote ("wind-up")
        hspd = -facing * 0.8;
        vspd += grv;
        
        // Pisca entre amarelo e laranja para avisar o jogador
        image_blend = ((action_timer div 3) mod 2 == 0) ? c_yellow : c_orange;
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.investida;
            action_timer = 28; // Duração do bote feroz
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 3;
            }
        }
        break;

    // --- ESTADO 4: INVESTIDA FEROZ (DIREÇÃO TRAVADA) ---
    case centopeia_state.investida:
        hspd = facing * 5.8; 
        vspd += grv;
        image_blend = c_fuchsia; // Destaque visual de ataque letal
        
        // Se bater de cara na parede durante a investida, interrompe e fica tonta!
        if (place_meeting(x + hspd, y, obj_colisor)) {
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 6;
            }
            hspd = -facing * 2;
            vspd = -3;
            state = centopeia_state.recuperando;
            action_timer = 55; // Janela extra por ter batido na parede!
            break;
        }
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.recuperando;
            action_timer = 45; // 45 frames recuperando o fôlego (Hora de bater!)
        }
        break;

    // --- ESTADO 4.5: RECUPERANDO O FÔLEGO (JANELA DE KITE!) ---
    case centopeia_state.recuperando:
        hspd = lerp(hspd, 0, 0.15); // Freia derrapando no chão
        vspd += grv;
        image_blend = c_gray; // Cor mais apagada indicando vulnerabilidade/cansaço
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.patrulha_luta;
            action_timer = 75;
        }
        break;

    // --- ESTADO 5: CUSPINDO ÁCIDO (DIREÇÃO TRAVADA PARA PUNIR PELAS COSTAS) ---
    case centopeia_state.cuspindo:
        hspd = 0;
        vspd += grv;
        image_blend = c_lime;
        
        // NOTA: Não atualizamos o "facing" aqui dentro! Se o rato rolar para trás dela,
        // ela continua cuspindo para o lado antigo e fica aberta a ataques pelas costas!
        action_timer--;
        
        if ((action_timer == 42 || action_timer == 26 || action_timer == 10) && object_exists(obj_acido_centopeia)) {
            var tiro = instance_create_layer(x + (facing * 20), y - 16, layer, obj_acido_centopeia);
            var dist_x = instance_exists(obj_player) ? abs(obj_player.x - x) : 120;
            var forca_h = clamp(dist_x / 35, 3, 7) + random_range(-0.8, 0.8);
            
            tiro.hspd = facing * forca_h;
            tiro.vspd = random_range(-6.5, -4.5);
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 2;
            }
        }
        
        if (action_timer <= 0) {
            // Pequeno respiro de 25 frames após terminar a rajada de ácido
            state = centopeia_state.recuperando;
            action_timer = 25;
        }
        break;
        
    // --- ESTADO 6: CAVANDO (FUGINDO PARA O SUBTERRÂNEO) ---
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
    
    if (instance_exists(obj_player)) {
        obj_player.arma_xp += 50;
    }
    
    instance_destroy();
} // <-- Fechamento do if (hp <= 0)