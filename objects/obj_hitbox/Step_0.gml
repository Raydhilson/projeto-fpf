if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

var _alvo = instance_place(x, y, obj_enemy);
if (_alvo == noone && object_exists(obj_vespa)) {
    _alvo = instance_place(x, y, obj_vespa);
}
if (_alvo == noone && object_exists(obj_boss_centopeia)) {
    _alvo = instance_place(x, y, obj_boss_centopeia);
}

if (_alvo != noone) {
    var _pode_acertar = true;
    if (_alvo.object_index == obj_boss_centopeia) {
        if (_alvo.state == centopeia_state.subterranea || _alvo.state == centopeia_state.emergindo) {
            _pode_acertar = false;
        }
    }
    
    if (_pode_acertar && _alvo.piscar <= 0) {
        var dano_final = dano;
        var foi_critico = false;
        
        var chance = variable_global_exists("chance_critico") ? global.chance_critico : 15;
        if (instance_exists(obj_player) && obj_player.arma_nivel >= 3) {
            chance = 30;
        }
        
        if (random(100) < chance) {
            foi_critico = true;
            var mult = variable_global_exists("multiplicador_crit") ? global.multiplicador_crit : 2.0;
            dano_final = dano * mult;
        }
        
        _alvo.hp -= dano_final;
        _alvo.piscar = 10;
        
        if (aplica_fogo && variable_instance_exists(_alvo, "queimando_timer")) {
            _alvo.queimando_timer = 180;
        }
        
        if (_alvo.object_index != obj_boss_centopeia) {
            var kb_forca = foi_critico ? 9 : 6;
            _alvo.hspd = sign(image_xscale) * kb_forca;
            _alvo.vspd = -4;
        }
        
        // Som de impacto personalizado por criatura!
        if (_alvo.object_index == obj_boss_centopeia) {
            tocar_sfx("snd_centipede_crawl", 0.85, 1.05);
        } else if (object_exists(obj_vespa) && _alvo.object_index == obj_vespa) {
            tocar_sfx("snd_wasp_sting", 0.9, 1.1);
        } else {
            tocar_sfx("snd_beetle_carapace", foi_critico ? 0.8 : 0.95, foi_critico ? 0.9 : 1.1);
        }
        
        if (instance_exists(obj_game_controller)) {
            if (foi_critico) {
                obj_game_controller.hitstop_timer = 10;
                obj_game_controller.shake_magnitude = 5;
            } else {
                obj_game_controller.hitstop_timer = 4;
                obj_game_controller.shake_magnitude = 1.5;
            }
        }
    }
}

duracao--;
if (duracao <= 0) {
    instance_destroy();
}