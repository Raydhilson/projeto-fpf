draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu);

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _pt = (!variable_global_exists("idioma") || global.idioma == "PT");

// ==========================================
// TELA 0: CAPA DO JOGO (MENU PRINCIPAL)
// ==========================================
if (menu_state == 0) {
    // Título traduzido
    draw_set_color(c_white);
    draw_text(_gw / 2, _gh / 3, _pt ? "TNK GAMES APRESENTA" : "TNK GAMES PRESENTS");
    
    draw_set_color(make_color_rgb(200, 120, 50)); // Cor de ferrugem/sucata
    draw_text(_gw / 2, (_gh / 3) + 30, _pt ? "PROJETO FPF: SOBREVIVENCIA" : "PROJECT FPF: SURVIVAL");
    
    var _spacing = 40;
    
    for (var i = 0; i < array_length(options); i++) {
        var _option = options[i];
        var _text = "";
        
        switch (_option) {
            case "new_game":      _text = _pt ? "Novo Jogo" : "New Game"; break;
            case "continue_game": _text = _pt ? "Continuar" : "Continue"; break;
            case "options":       _text = _pt ? "Opcoes"    : "Options";  break;
            case "quit":          _text = _pt ? "Sair"      : "Quit";     break;
        }
        
        var _yy = (_gh / 2) + 40 + (i * _spacing);
        
        if (_option == "continue_game" && !has_save) {
            draw_set_color(c_dkgray);
            draw_text(_gw / 2, _yy, _text);
        } else if (i == menu_index) {
            draw_set_color(c_yellow);
            draw_text(_gw / 2, _yy, ">> " + _text + " <<");
        } else {
            draw_set_color(c_gray);
            draw_text(_gw / 2, _yy, _text);
        }
    }
}
// ==========================================
// TELA 1: SUB-MENU DE OPÇÕES E CONTROLES
// ==========================================
else if (menu_state == 1) {
    draw_set_color(c_white);
    draw_text(_gw / 2, _gh * 0.10, _pt ? "--- OPCOES E CONTROLES ---" : "--- OPTIONS & CONTROLS ---");
    
    var txt_sim    = _pt ? "SIM" : "ON";
    var txt_nao    = _pt ? "NAO" : "OFF";
    var txt_espera = _pt ? "[ PRESSIONE UMA TECLA... ]" : "[ PRESS ANY KEY... ]";
    
    var lista_cfg = [
        (_pt ? "IDIOMA: " : "LANGUAGE: ") + global.idioma,
        (_pt ? "TELA CHEIA: " : "FULLSCREEN: ") + (window_get_fullscreen() ? txt_sim : txt_nao),
        (_pt ? "TREMER TELA: " : "SCREEN SHAKE: ") + (global.tremer_tela ? txt_sim : txt_nao),
        (_pt ? "PULO: " : "JUMP: ") + ((aguardando_tecla && menu_index == 3) ? txt_espera : nome_tecla(global.key_jump)),
        (_pt ? "ATAQUE: " : "ATTACK: ") + ((aguardando_tecla && menu_index == 4) ? txt_espera : nome_tecla(global.key_attack)),
        (_pt ? "ESQUIVA: " : "ROLL: ") + ((aguardando_tecla && menu_index == 5) ? txt_espera : nome_tecla(global.key_roll)),
        (_pt ? "CURAR: " : "HEAL: ") + ((aguardando_tecla && menu_index == 6) ? txt_espera : nome_tecla(global.key_heal)),
        (_pt ? "MOLOTOV: " : "THROW: ") + ((aguardando_tecla && menu_index == 7) ? txt_espera : nome_tecla(global.key_throw)),
        (_pt ? "ANDAR ESQ: " : "MOVE LEFT: ") + ((aguardando_tecla && menu_index == 8) ? txt_espera : nome_tecla(global.key_left)),
        (_pt ? "ANDAR DIR: " : "MOVE RIGHT: ") + ((aguardando_tecla && menu_index == 9) ? txt_espera : nome_tecla(global.key_right)),
        (_pt ? "VOLTAR E SALVAR" : "BACK & SAVE")
    ];
    
    for (var j = 0; j < array_length(lista_cfg); j++) {
        var yy = (_gh * 0.20) + (j * 24);
        if (menu_index == j) {
            draw_set_color(aguardando_tecla ? c_orange : c_yellow);
            draw_text(_gw / 2, yy, ">> " + lista_cfg[j] + " <<");
        } else {
            draw_set_color(c_gray);
            draw_text(_gw / 2, yy, lista_cfg[j]);
        }
    }
}

// Reseta a formatação
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);