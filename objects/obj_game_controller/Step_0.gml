if (!variable_instance_exists(id, "is_paused"))          is_paused = false;
if (!variable_instance_exists(id, "is_dead"))            is_dead = false;
if (!variable_instance_exists(id, "escolhendo_carta"))   escolhendo_carta = false;
if (!variable_instance_exists(id, "portao_hp"))          portao_hp = 200;
if (!variable_instance_exists(id, "aguardando_ok_wave")) aguardando_ok_wave = true;

if (room != rm_main_menu && room != rm_options) {
    view_enabled = true;
    view_visible[0] = true;
    if (!instance_exists(obj_camera) && instance_exists(obj_player)) {
        instance_create_depth(obj_player.x, obj_player.y, 0, obj_camera);
    }
}

if (keyboard_check_pressed(vk_f11)) {
    global.tela_cheia = !window_get_fullscreen();
    aplicar_resolucao();
    salvar_configuracoes();
}

// ATALHOS DE APRESENTAÇÃO (F2 = Abrir Cartas | F3 = Chamar Wave do Boss)
if (keyboard_check_pressed(vk_f2) && !is_dead) {
    var _pool = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    for (var c = 0; c < 3; c++) {
        var _r = irandom(array_length(_pool) - 1);
        cartas_opcoes[c] = _pool[_r];
        array_delete(_pool, _r, 1);
    }
    escolhendo_carta = true;
    carta_index = 1;
    tocar_sfx("snd_save_shrine");
    instance_deactivate_all(true);
    instance_activate_object(obj_game_controller);
}
if (keyboard_check_pressed(vk_f3) && !is_dead) {
    with (obj_enemy) instance_destroy();
    wave_atual = 4;
    wave_timer = 0;
    aguardando_ok_wave = false;
    wave_cooldown = 10;
}

// =======================================================
// 0. TELA DE FIM DE JOGO
// =======================================================
if (is_dead) {
    registrar_no_ranking();
    death_alpha = min(1.0, death_alpha + 0.04);
    
    var key_up      = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(global.key_up)    || gamepad_button_check_pressed(0, gp_padu);
    var key_down    = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || keyboard_check_pressed(global.key_down)  || gamepad_button_check_pressed(0, gp_padd);
    var key_confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);
    
    if (key_up || key_down) {
        death_index = (death_index == 0) ? 1 : 0;
        tocar_sfx("snd_ui_move");
    }
    
    if (key_confirm) {
        tocar_sfx("snd_ui_confirm");
        is_dead = false;
        score_registrado = false;
        death_alpha = 0;
        escolhendo_carta = false;
        instance_activate_all();
        
        wave_atual = 0;
        wave_timer = 0;
        wave_cooldown = 60;
        aguardando_ok_wave = true;
        tempo_sobrevivido_frames = 0;
        portao_hp_max = 200;
        portao_hp = portao_hp_max;
        portao_espinhos = 0;
        global.score_atual = 0;
        global.scrap = 5;
        
        if (death_index == 0) {
            room_restart();
        } else {
            room_goto(rm_main_menu);
        }
    }
    exit;
}

// =======================================================
// 0.5 ESCOLHA DE CARTAS ROGUELIKE (12 OPÇÕES)
// =======================================================
if (escolhendo_carta) {
    var key_left    = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(global.key_left)  || gamepad_button_check_pressed(0, gp_padl);
    var key_right   = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(global.key_right) || gamepad_button_check_pressed(0, gp_padr);
    var key_confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);
    
    if (key_left)  { carta_index--; if (carta_index < 0) carta_index = 2; tocar_sfx("snd_ui_move"); }
    if (key_right) { carta_index++; if (carta_index > 2) carta_index = 0; tocar_sfx("snd_ui_move"); }
    
    if (key_confirm) {
        tocar_sfx("snd_craft_success", 0.95, 1.1);
        instance_activate_all();
        
        var _id_escolhido = cartas_opcoes[carta_index];
        if (instance_exists(obj_player)) {
            switch (_id_escolhido) {
                case 0:
                    global.ataque_base += 5;
                    obj_player.hp = min(obj_player.hp_max, obj_player.hp + 25);
                    break;
                case 1:
                    obj_player.spin_cooldown_max = max(90, obj_player.spin_cooldown_max - 90);
                    obj_player.spin_dano_bonus += 2;
                    break;
                case 2:
                    portao_hp_max += 80;
                    portao_hp = min(portao_hp_max, portao_hp + 100);
                    if (instance_exists(obj_barricada)) {
                        obj_barricada.hp_max = portao_hp_max;
                        obj_barricada.hp = portao_hp;
                    }
                    break;
                case 3:
                    obj_player.hp_max += 35;
                    obj_player.hp = min(obj_player.hp_max, obj_player.hp + 50);
                    break;
                case 4:
                    obj_player.buff_fogo_timer += 2100;
                    obj_player.molotov_count += 2;
                    break;
                case 5:
                    global.scrap += 8;
                    obj_player.faca_count += 3;
                    obj_player.curativo_count += 1;
                    break;
                case 6:
                    global.chance_critico = min(100, global.chance_critico + 20);
                    global.multiplicador_crit += 0.5;
                    break;
                case 7:
                    obj_player.walk_sp += 1.0;
                    obj_player.roll_sp += 1.5;
                    break;
                case 8:
                    obj_player.vampirismo_hp += 4;
                    global.ataque_base += 3;
                    break;
                case 9:
                    portao_espinhos += 2;
                    portao_hp = min(portao_hp_max, portao_hp + 60);
                    break;
                case 10:
                    obj_player.faca_count += 6;
                    global.chance_critico = min(100, global.chance_critico + 15);
                    break;
                case 11:
                    obj_player.hp = obj_player.hp_max;
                    obj_player.curativo_count += 3;
                    global.scrap += 5;
                    break;
            }
        }
        
        escolhendo_carta = false;
        
        if (wave_atual mod 2 == 0) {
            aguardando_ok_wave = true;
        } else {
            aguardando_ok_wave = false;
            wave_cooldown = 120;
        }
        keyboard_clear(vk_enter);
    }
    exit;
}

// =======================================================
// GERENCIAMENTO DE WAVES E SPAWN AUTOMÁTICO DE MONSTROS
// =======================================================
if (room != rm_main_menu && room != rm_options) {
    if (instance_exists(obj_barricada)) {
        portao_hp = obj_barricada.hp;
        portao_hp_max = obj_barricada.hp_max;
    }
    
    var _player_em_menu = (instance_exists(obj_player) && obj_player.state == player_state.menu);
    
    if (!_player_em_menu && !is_paused) {
        var _inimigos_vivos = instance_number(obj_enemy);
        
        if (_inimigos_vivos == 0) {
            if (wave_atual > 0 && wave_timer > 0) {
                var _bonus_tempo = ceil(wave_timer / 60) * 15;
                global.score_atual += (wave_atual * 150) + _bonus_tempo;
                wave_timer = 0;
                
                var _pool = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
                for (var c = 0; c < 3; c++) {
                    var _r = irandom(array_length(_pool) - 1);
                    cartas_opcoes[c] = _pool[_r];
                    array_delete(_pool, _r, 1);
                }
                
                carta_index = 1;
                escolhendo_carta = true;
                tocar_sfx("snd_save_shrine", 1.0, 1.1);
                instance_deactivate_all(true);
                instance_activate_object(obj_game_controller);
                exit;
            }
            
            if (aguardando_ok_wave) {
                if (keyboard_check_pressed(vk_enter) || gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(0, gp_face1)) {
                    aguardando_ok_wave = false;
                    wave_cooldown = 45;
                    tocar_sfx("snd_ui_confirm", 0.9, 1.1);
                }
            }
            else if (wave_cooldown > 0) {
                wave_cooldown--;
            } else {
                // INICIA NOVA WAVE E SPAWNA OS MONSTROS NA DIREITA DA SALA!
                wave_atual++;
                wave_timer_max = (45 + (wave_atual * 5)) * 60;
                wave_timer = wave_timer_max;
                shake_magnitude = 5;
                
                var _qtd_total = 3 + wave_atual;
                var _base_y = instance_exists(obj_player) ? (obj_player.y - 40) : 450;
                var _spawn_min_x = instance_exists(obj_player) ? max(750, obj_player.x + 300) : 850;
                var _spawn_max_x = room_width - 100;
                
                if (wave_atual mod 5 == 0) {
                    tocar_sfx("snd_centipede_roar");
                    var _boss = instance_create_depth(_spawn_max_x - 50, _base_y - 20, 0, obj_boss_centopeia);
                    _boss.spawn_alpha = 0;
                    _boss.spawn_scale = 0.1;
                } else {
                    tocar_sfx("snd_beetle_charge");
                }
                
                for (var s = 0; s < _qtd_total; s++) {
                    var _sx = random_range(_spawn_min_x, _spawn_max_x) + (s * 35);
                    _sx = clamp(_sx, 500, room_width - 64);
                    
                    if (wave_atual >= 2 && irandom(99) < 35) {
                        var _v = instance_create_depth(_sx, _base_y - random_range(40, 75), 0, obj_vespa);
                        _v.hp = 2 + floor(wave_atual * 0.5);
                        _v.spawn_alpha = 0;
                        _v.spawn_scale = 0.1;
                    } else {
                        var _e = instance_create_depth(_sx, _base_y, 0, obj_enemy);
                        _e.hp = 3 + floor(wave_atual * 0.7);
                        _e.spawn_alpha = 0;
                        _e.spawn_scale = 0.1;
                    }
                }
            }
        } else {
            tempo_sobrevivido_frames++;
            if (wave_timer > 0) {
                wave_timer--;
                if (wave_timer <= 0) {
                    wave_timer = 0;
                    is_dead = true;
                    motivo_derrota = 3;
                    death_index = 0;
                    death_alpha = 0;
                    tocar_sfx("snd_centipede_roar", 0.7, 0.8);
                    instance_deactivate_all(true);
                    instance_activate_object(obj_game_controller);
                    exit;
                }
            }
        }
    }
}

// =======================================================
// 1. MODO DE REBIND
// =======================================================
if (is_paused && pause_state == 1 && opcao_aba == 1 && aguardando_tecla) {
    if (keyboard_check_pressed(vk_anykey)) {
        var nova_tecla = keyboard_lastkey;
        if (nova_tecla != vk_escape && nova_tecla != vk_f11) {
            switch (pause_index) {
                case 0:  global.key_jump   = nova_tecla; break;
                case 1:  global.key_attack = nova_tecla; break;
                case 2:  global.key_roll   = nova_tecla; break;
                case 3:  global.key_heal   = nova_tecla; break;
                case 4:  global.key_throw  = nova_tecla; break;
                case 5:  global.key_left   = nova_tecla; break;
                case 6:  global.key_right  = nova_tecla; break;
            }
            salvar_configuracoes();
            tocar_sfx("snd_ui_confirm");
        }
        aguardando_tecla = false;
        keyboard_clear(vk_anykey);
    }
    exit;
}

// =======================================================
// 2. GATILHO DO PAUSE
// =======================================================
var key_pause = keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0, gp_start);

if (key_pause && room != rm_main_menu) {
    if (instance_exists(obj_player) && obj_player.state == player_state.menu) {
        exit; 
    }

    if (!is_paused) {
        is_paused = true;
        pause_state = 0;
        pause_index = 0;
        aguardando_tecla = false;
        instance_deactivate_all(true);
        tocar_sfx("snd_ui_move");
    } else {
        if (pause_state == 1) {
            salvar_configuracoes();
            pause_state = 0;
            pause_index = 1; 
            tocar_sfx("snd_ui_back");
        } else {
            is_paused = false;
            instance_activate_all();
            tocar_sfx("snd_ui_back");
        }
    }
    keyboard_clear(vk_escape);
    exit; 
}

// =======================================================
// 3. NAVEGAÇÃO DO MENU DE PAUSE
// =======================================================
if (is_paused) {
    var key_up      = keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W")) || keyboard_check_pressed(global.key_up)    || gamepad_button_check_pressed(0, gp_padu);
    var key_down    = keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S")) || keyboard_check_pressed(global.key_down)  || gamepad_button_check_pressed(0, gp_padd);
    var key_left    = keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(global.key_left)  || gamepad_button_check_pressed(0, gp_padl);
    var key_right   = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(global.key_right) || gamepad_button_check_pressed(0, gp_padr);
    var key_confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(global.key_confirm) || gamepad_button_check_pressed(0, gp_face1);
    
    if (pause_state == 0) {
        var total_opcoes = 3;
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes - 1; tocar_sfx("snd_ui_move"); }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes) pause_index = 0; tocar_sfx("snd_ui_move"); }
        
        if (key_confirm) {
            tocar_sfx("snd_ui_confirm");
            if (pause_index == 0) {
                is_paused = false;
                instance_activate_all();
            } else if (pause_index == 1) {
                pause_state = 1;
                opcao_aba = 0;
                pause_index = 0;
            } else if (pause_index == 2) {
                registrar_no_ranking();
                salvar_configuracoes();
                is_paused = false;
                instance_activate_all();
                room_goto(rm_main_menu);
            }
        }
    }
    else if (pause_state == 1) {
        if (!variable_instance_exists(id, "opcao_aba")) opcao_aba = 0;
        
        var tab_l = keyboard_check_pressed(global.key_tab_left)  || gamepad_button_check_pressed(0, gp_shoulderl);
        var tab_r = keyboard_check_pressed(global.key_tab_right) || gamepad_button_check_pressed(0, gp_shoulderr);
        
        if (tab_l) { opcao_aba = 0; pause_index = 0; tocar_sfx("snd_ui_move"); }
        if (tab_r) { opcao_aba = 1; pause_index = 0; tocar_sfx("snd_ui_move"); }
        
        var total_opcoes_aba = (opcao_aba == 0) ? 7 : 8;
        
        if (key_up)   { pause_index--; if (pause_index < 0) pause_index = total_opcoes_aba - 1; tocar_sfx("snd_ui_move"); }
        if (key_down) { pause_index++; if (pause_index >= total_opcoes_aba) pause_index = 0; tocar_sfx("snd_ui_move"); }
        
        var key_toggle = key_confirm || key_left || key_right;
        
        if (opcao_aba == 0) {
            if (pause_index == 0 && (key_left || key_right || key_confirm)) {
                if (key_left) global.vol_master = clamp(global.vol_master - 0.1, 0.0, 1.0);
                if (key_right || key_confirm) {
                    global.vol_master += 0.1;
                    if (global.vol_master > 1.0) global.vol_master = 0.0;
                }
                audio_master_gain(global.vol_master);
                salvar_configuracoes();
                tocar_sfx("snd_ui_move");
            }
            else if (key_toggle && (pause_index == 1 || pause_index == 2 || pause_index == 4)) {
                switch (pause_index) {
                    case 1: global.idioma = (global.idioma == "PT") ? "EN" : "PT"; break;
                    case 2:
                        global.tela_cheia = !window_get_fullscreen();
                        aplicar_resolucao();
                        break;
                    case 4: global.tremer_tela = !global.tremer_tela; break;
                }
                salvar_configuracoes();
                tocar_sfx("snd_ui_confirm");
            }
            else if (pause_index == 3 && (key_left || key_right || key_confirm)) {
                if (!variable_global_exists("res_index")) global.res_index = 0;
                if (key_left) global.res_index--; else global.res_index++;
                if (global.res_index < 0) global.res_index = 2;
                if (global.res_index > 2) global.res_index = 0;
                aplicar_resolucao();
                salvar_configuracoes();
                tocar_sfx("snd_ui_confirm");
            }
            else if (pause_index == 5 && (key_left || key_right || key_confirm)) {
                if (key_left) global.brilho = clamp(global.brilho - 0.1, 0.1, 1.0);
                if (key_right || key_confirm) {
                    global.brilho += 0.1;
                    if (global.brilho > 1.0) global.brilho = 0.1;
                }
                salvar_configuracoes();
                tocar_sfx("snd_ui_move");
            }
            else if (key_confirm && pause_index == 6) {
                salvar_configuracoes();
                pause_state = 0;
                pause_index = 1;
                tocar_sfx("snd_ui_back");
            }
        }
        else if (opcao_aba == 1) {
            if (key_confirm) {
                if (pause_index >= 0 && pause_index <= 6) {
                    aguardando_tecla = true;
                    keyboard_clear(vk_anykey);
                    tocar_sfx("snd_ui_confirm");
                } else if (pause_index == 7) {
                    salvar_configuracoes();
                    pause_state = 0;
                    pause_index = 1;
                    tocar_sfx("snd_ui_back");
                }
            }
        }
    }
}

if (is_paused) exit;

if (hitstop_timer > 0) {
    hitstop_timer--;
    with (all) {
        if (variable_instance_exists(id, "hspd") && variable_instance_exists(id, "vspd")) {
            if (!variable_instance_exists(id, "hspd_save") || is_undefined(hspd_save)) {
                hspd_save = hspd;
                vspd_save = vspd;
                image_speed_save = image_speed;
            }
            hspd = 0;
            vspd = 0;
            image_speed = 0;
        }
    }
} else {
    with (all) {
        if (variable_instance_exists(id, "hspd_save") && !is_undefined(hspd_save)) {
            hspd = hspd_save;
            vspd = vspd_save;
            image_speed = image_speed_save;
            hspd_save = undefined;
        }
    }
}