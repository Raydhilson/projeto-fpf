var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _pt = (!variable_global_exists("idioma") || global.idioma == "PT");

draw_set_font(fnt_menu);

// Paleta de Cores Dark Fantasy / Indie UI
var col_bg_panel   = make_color_rgb(18, 20, 26);
var col_header     = make_color_rgb(28, 32, 42);
var col_border_out = make_color_rgb(90, 80, 65);
var col_gold       = make_color_rgb(235, 185, 60);
var col_highlight  = make_color_rgb(45, 50, 65);
var col_text_off   = make_color_rgb(150, 155, 165);

// Fundo escuro elegante
draw_set_color(make_color_rgb(10, 12, 16));
draw_rectangle(0, 0, _gw, _gh, false);

// ==========================================
// TELA 0: CAPA DO JOGO (MENU PRINCIPAL)
// ==========================================
if (menu_state == 0) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Placa Superior do Título (Banner)
    var bw = min(460, _gw * 0.85);
    var bh = 86;
    var bx = (_gw - bw) / 2;
    var by = (_gh * 0.14);
    
    draw_set_color(col_bg_panel);
    draw_rectangle(bx, by, bx + bw, by + bh, false);
    draw_set_color(col_border_out);
    draw_rectangle(bx, by, bx + bw, by + bh, true);
    draw_set_color(col_gold);
    draw_rectangle(bx + 3, by + 3, bx + bw - 3, by + bh - 3, true);
    
    draw_set_color(col_text_off);
    draw_text(_gw / 2, by + 26, _pt ? "TNK GAMES APRESENTA" : "TNK GAMES PRESENTS");
    
    draw_set_color(col_gold);
    draw_text(_gw / 2, by + 56, _pt ? "PROJETO FPF: SOBREVIVENCIA" : "PROJECT FPF: SURVIVAL");
    
    // Caixa Central de Botões do Menu Inicial
    var mw = min(320, _gw * 0.75);
    var mh = (array_length(options) * 44) + 28;
    var mx = (_gw - mw) / 2;
    var my = (_gh * 0.44);
    
    draw_set_color(col_bg_panel);
    draw_rectangle(mx, my, mx + mw, my + mh, false);
    draw_set_color(col_border_out);
    draw_rectangle(mx, my, mx + mw, my + mh, true);
    
    for (var i = 0; i < array_length(options); i++) {
        var _option = options[i];
        var _text = "";
        
        switch (_option) {
            case "new_game":      _text = _pt ? "NOVO JOGO" : "NEW GAME"; break;
            case "continue_game": _text = _pt ? "CONTINUAR" : "CONTINUE"; break;
            case "options":       _text = _pt ? "OPCOES"    : "OPTIONS";  break;
            case "quit":          _text = _pt ? "SAIR"      : "QUIT";     break;
        }
        
        var _yy = my + 34 + (i * 44);
        var rx1 = mx + 18;
        var rx2 = mx + mw - 18;
        
        if (_option == "continue_game" && !has_save) {
            draw_set_color(c_dkgray);
            draw_text(_gw / 2, _yy, _text);
        } else if (i == menu_index) {
            draw_set_color(col_highlight);
            draw_rectangle(rx1, _yy - 16, rx2, _yy + 16, false);
            draw_set_color(col_gold);
            draw_rectangle(rx1, _yy - 16, rx1 + 5, _yy + 16, false);
            draw_rectangle(rx1, _yy - 16, rx2, _yy + 16, true);
            
            draw_set_color(c_white);
            draw_text(_gw / 2, _yy, _text);
        } else {
            draw_set_color(col_text_off);
            draw_text(_gw / 2, _yy, _text);
        }
    }
}
// ==========================================
// TELA 1: SUB-MENU DE OPÇÕES E CONTROLES (EM ABAS)
// ==========================================
else if (menu_state == 1) {
    var pw = min(540, _gw * 0.90);
    var ph = min(340, _gh * 0.86);
    var px = (_gw - pw) / 2;
    var py = (_gh - ph) / 2;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
    
    var aba_ativa = (menu_index >= 4 && menu_index <= 10) ? 1 : 0;
    var tab_w = (pw - 6) / 2;
    var tab_h = 38;
    var nomes_abas = [
        _pt ? "1. GERAL E VIDEO" : "1. GENERAL & VIDEO",
        _pt ? "2. CONTROLES (TECLAS)" : "2. CONTROLS (KEYS)"
    ];
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    for (var t = 0; t < 2; t++) {
        var tx1 = px + 3 + (t * tab_w);
        var tx2 = tx1 + tab_w;
        var ty1 = py + 3;
        var ty2 = ty1 + tab_h;
        
        if (aba_ativa == t) {
            draw_set_color(col_highlight);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_gold);
            draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
            draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t]);
        } else {
            draw_set_color(col_header);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_text_off);
            draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t]);
        }
    }
    
    var txt_sim     = _pt ? "LIGADO" : "ON";
    var txt_nao     = _pt ? "DESLIGADO" : "OFF";
    var txt_espera  = _pt ? "PRESSIONE TECLA..." : "PRESS ANY KEY...";
    var val_brilho  = clamp(variable_global_exists("brilho") ? global.brilho : 0.5, 0.1, 1.0);
    var _brilho_pct = string(round(val_brilho * 100)) + "%";
    
    var labels = [
        _pt ? "Idioma do Jogo" : "Game Language",
        _pt ? "Modo Tela Cheia" : "Fullscreen Mode",
        _pt ? "Tremor de Tela (Shake)" : "Screen Shake",
        _pt ? "Nivel de Brilho" : "Brightness Level",
        _pt ? "Pular" : "Jump",
        _pt ? "Atacar (Lanca)" : "Attack (Spear)",
        _pt ? "Esquivar (Roll)" : "Dodge (Roll)",
        _pt ? "Usar Curativo" : "Use Bandage",
        _pt ? "Arremessar Item" : "Throw Item",
        _pt ? "Mover para Esquerda" : "Move Left",
        _pt ? "Mover para Direita" : "Move Right"
    ];
    
    var values = [
        "< " + global.idioma + " >",
        "< " + (window_get_fullscreen() ? txt_sim : txt_nao) + " >",
        "< " + (global.tremer_tela ? txt_sim : txt_nao) + " >",
        "< " + _brilho_pct + " >",
        (aguardando_tecla && menu_index == 4)  ? txt_espera : "[ " + nome_tecla(global.key_jump) + " ]",
        (aguardando_tecla && menu_index == 5)  ? txt_espera : "[ " + nome_tecla(global.key_attack) + " ]",
        (aguardando_tecla && menu_index == 6)  ? txt_espera : "[ " + nome_tecla(global.key_roll) + " ]",
        (aguardando_tecla && menu_index == 7)  ? txt_espera : "[ " + nome_tecla(global.key_heal) + " ]",
        (aguardando_tecla && menu_index == 8)  ? txt_espera : "[ " + nome_tecla(global.key_throw) + " ]",
        (aguardando_tecla && menu_index == 9)  ? txt_espera : "[ " + nome_tecla(global.key_left) + " ]",
        (aguardando_tecla && menu_index == 10) ? txt_espera : "[ " + nome_tecla(global.key_right) + " ]"
    ];
    
    var idx_ini = (aba_ativa == 0) ? 0 : 4;
    var idx_fim = (aba_ativa == 0) ? 3 : 10;
    var row_h   = (aba_ativa == 0) ? 38 : 26;
    var list_y  = py + 66;
    
    for (var idx = idx_ini; idx <= idx_fim; idx++) {
        var line_num = idx - idx_ini;
        var yy  = list_y + (line_num * row_h);
        var rx1 = px + 22;
        var rx2 = px + pw - 22;
        var is_sel = (menu_index == idx);
        
        if (is_sel) {
            draw_set_color(col_highlight);
            draw_rectangle(rx1, yy - (row_h * 0.42), rx2, yy + (row_h * 0.42), false);
            draw_set_color(aguardando_tecla ? c_orange : col_gold);
            draw_rectangle(rx1, yy - (row_h * 0.42), rx1 + 4, yy + (row_h * 0.42), false);
        }
        
        draw_set_halign(fa_left);
        draw_set_color(is_sel ? c_white : col_text_off);
        draw_text(rx1 + 14, yy, labels[idx]);
        
        draw_set_halign(fa_right);
        draw_set_color(is_sel ? (aguardando_tecla ? c_orange : col_gold) : c_ltgray);
        
        if (idx == 3) {
            var bar_w = 80;
            var bar_h = 8;
            var bar_x1 = rx2 - 75 - bar_w;
            var bar_y1 = yy - (bar_h / 2);
            draw_set_color(c_dkgray);
            draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);
            draw_set_color(is_sel ? col_gold : c_gray);
            draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * val_brilho), bar_y1 + bar_h, false);
            draw_text(rx2 - 12, yy, values[idx]);
        } else {
            draw_text(rx2 - 12, yy, values[idx]);
        }
    }
    
    var div_y = py + ph - 52;
    draw_set_color(col_border_out);
    draw_line(px + 16, div_y, px + pw - 16, div_y);
    
    var btn_y = py + ph - 26;
    var b1_x  = px + (pw * 0.28);
    var b2_x  = px + (pw * 0.74);
    
    draw_set_halign(fa_center);
    
    var txt_reset = _pt ? "RESTAURAR PADROES" : "RESET DEFAULTS";
    if (menu_index == 11) {
        draw_set_color(col_highlight);
        draw_rectangle(b1_x - 110, btn_y - 14, b1_x + 110, btn_y + 14, false);
        draw_set_color(col_gold);
        draw_rectangle(b1_x - 110, btn_y - 14, b1_x + 110, btn_y + 14, true);
        draw_text(b1_x, btn_y, txt_reset);
    } else {
        draw_set_color(col_text_off);
        draw_text(b1_x, btn_y, txt_reset);
    }
    
    var txt_back = _pt ? "VOLTAR E SALVAR" : "BACK & SAVE";
    if (menu_index == 12) {
        draw_set_color(col_highlight);
        draw_rectangle(b2_x - 100, btn_y - 14, b2_x + 100, btn_y + 14, false);
        draw_set_color(col_gold);
        draw_rectangle(b2_x - 100, btn_y - 14, b2_x + 100, btn_y + 14, true);
        draw_text(b2_x, btn_y, txt_back);
    } else {
        draw_set_color(col_text_off);
        draw_text(b2_x, btn_y, txt_back);
    }
}

// Rodapé de Dicas de Controle
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(col_text_off);
var dica_menu = _pt 
    ? "[W/S] Navegar    [ENTER / A] Confirmar    [ESC / B] Voltar" 
    : "[W/S] Navigate    [ENTER / A] Confirm    [ESC / B] Back";
draw_text(_gw / 2, _gh - 18, dica_menu);

// ==========================================
// EFEITO DE BRILHO NO MENU INICIAL
// ==========================================
if (variable_global_exists("brilho")) {
    if (global.brilho < 0.5) {
        draw_set_color(c_black);
        draw_set_alpha((0.5 - global.brilho) * 1.4);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1.0);
    } else if (global.brilho > 0.5) {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha((global.brilho - 0.5) * 0.6);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1.0);
        gpu_set_blendmode(bm_normal);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);