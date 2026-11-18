if (!variable_instance_exists(id, "ja_acertou")) ja_acertou = false;
if (ja_acertou) exit;

var _dano_base = variable_global_exists("ataque_base") ? global.ataque_base : 10;
var _crit_chance = variable_global_exists("chance_critico") ? global.chance_critico : 15;
var _crit_mult = variable_global_exists("multiplicador_crit") ? global.multiplicador_crit : 2.0;

var _eh_critico = (irandom(99) < _crit_chance);
var _multiplicador_final = _eh_critico ? _crit_mult : 1.0;
var _dano_calculado = max(1, round((_dano_base / 10) * dano * _multiplicador_final));

other.hp -= _dano_calculado;
other.piscar = 4;
if (variable_instance_exists(id, "aplica_fogo") && aplica_fogo) {
    other.queimando_timer = 180;
}

ja_acertou = true;

// Bônus de Arma Nível 3 (Seguro contra erros)
if (instance_exists(obj_player) && variable_instance_exists(obj_player, "arma_nivel")) {
    if (obj_player.arma_nivel >= 3) {
        other.hp -= 1; // Dano extra por nível alto
    }
}

if (instance_exists(obj_game_controller)) {
    obj_game_controller.hitstop_timer = _eh_critico ? 6 : 3;
    obj_game_controller.shake_magnitude = _eh_critico ? 5 : 2;
}