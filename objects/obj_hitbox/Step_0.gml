duracao--;
if (duracao <= 0) {
    instance_destroy();
    exit;
}

var _dano_base = variable_global_exists("ataque_base") ? global.ataque_base : 10;
var _crit_chance = variable_global_exists("chance_critico") ? global.chance_critico : 15;
var _crit_mult = variable_global_exists("multiplicador_crit") ? global.multiplicador_crit : 2.0;

var _eh_critico = (irandom(99) < _crit_chance);
var _multiplicador_final = _eh_critico ? _crit_mult : 1.0;
var _dano_calculado = max(1, round((_dano_base / 10) * dano * _multiplicador_final));

// 1. Acerta Besouro ou Boss
var _inimigo = instance_place(x, y, obj_enemy);
if (_inimigo != noone && !ja_acertou) {
    _inimigo.hp -= _dano_calculado;
    _inimigo.piscar = 4;
    if (aplica_fogo) _inimigo.queimando_timer = 180;
    ja_acertou = true;
    
    if (instance_exists(obj_player)) {
        if (variable_instance_exists(obj_player, "vampirismo_hp") && obj_player.vampirismo_hp > 0) {
            obj_player.hp = min(obj_player.hp_max, obj_player.hp + obj_player.vampirismo_hp);
        }
    }
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = _eh_critico ? 6 : 3;
        obj_game_controller.shake_magnitude = _eh_critico ? 5 : 2;
    }
}

// 2. Acerta Vespa (Com Air Bounce se o player estiver no ar!)
if (object_exists(obj_vespa)) {
    var _vespa = instance_place(x, y, obj_vespa);
    if (_vespa != noone && !ja_acertou) {
        _vespa.hp -= _dano_calculado;
        _vespa.piscar = 4;
        ja_acertou = true;
        
        if (instance_exists(obj_player)) {
            // Impulso no ar ao acertar a Vespa!
            if (!place_meeting(obj_player.x, obj_player.y + 1, obj_colisor)) {
                obj_player.vspd = -5.5;
            }
            if (variable_instance_exists(obj_player, "vampirismo_hp") && obj_player.vampirismo_hp > 0) {
                obj_player.hp = min(obj_player.hp_max, obj_player.hp + obj_player.vampirismo_hp);
            }
        }
        if (instance_exists(obj_game_controller)) {
            obj_game_controller.hitstop_timer = 4;
            obj_game_controller.shake_magnitude = 3;
        }
    }
}