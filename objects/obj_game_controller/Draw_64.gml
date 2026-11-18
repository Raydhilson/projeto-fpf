if (display_get_gui_width() != 800) {
    display_set_gui_size(800, 450);
}

var gw = display_get_gui_width();
var gh = display_get_gui_height();
var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");

var _draw_txt = function(_x, _y, _str, _col) {
    draw_set_color(c_black);
    draw_text(round(_x) + 1, round(_y) + 1, _str);
    draw_set_color(_col);
    draw_text(round(_x), round(_y), _str);
};

// Função para formatar segundos em MM:SS
var _formatar_tempo = function(_seg_total) {
    var _m = floor(_seg_total / 60);
    var _s = _seg_total mod 60;
    var _str_m = (_m < 10) ? "0" + string(_m) : string(_m);
    var _str_s = (_s < 10) ? "0" + string(_s) : string(_s);
    return _str_m + ":" + _str_s;
};

// ==========================================
// 0. HUD DA ARENA (PORTÃO DO LAB, WAVE, TIMER E SCORE)
// ==========================================
if (room != rm_main_menu && room != rm_options && !is_paused && !is_dead && !escolhendo_carta) {
    var _player_menu = (instance_exists(obj_player) && (obj_player.state == player_state.menu || obj_player.state == player_state.craft));
    if (!_player_menu) {
        draw_set_font(fnt_menu);
        var _inimigos = instance_number(obj_enemy) + instance_number(obj_vespa) + instance_number(obj_boss_centopeia);
        
        // Painel Central Superior (Wave + Timer + Barra de HP do Portão do Laboratório)
        var _pw = 290;
        var _ph = 66;
        var _px = round((gw - _pw) / 2);
        var _py = 10;
        
        draw_set_color(make_color_rgb(14, 16, 22));
        draw_set_alpha(0.85);
        draw_rectangle(_px, _py, _px + _pw, _py + _ph, false);
        draw_set_alpha(1.0);
        
        var _col_gold = make_color_rgb(245, 195, 65);
        draw_set_color((portao_piscar > 0) ? c_red : _col_gold);
        draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        if (_inimigos == 0 && variable_instance_exists(id, "aguardando_ok_wave") && aguardando_ok_wave) {
            _draw_txt(gw / 2, _py + 14, is_pt ? "INTERVALO - APERTE [ENTER] P/ WAVE " + string(wave_atual + 1) : "BREAK - PRESS [ENTER] FOR WAVE " + string(wave_atual + 1), make_color_rgb(80, 215, 105));
        } else if (_inimigos == 0 && wave_cooldown > 0) {
            var _seg_prep = ceil(wave_cooldown / 60);
            _draw_txt(gw / 2, _py + 14, is_pt ? "PROXIMA WAVE EM " + string(_seg_prep) + "s" : "NEXT WAVE IN " + string(_seg_prep) + "s", _col_gold);
        } else {
            var _seg_rest = ceil(wave_timer / 60);
            var _cor_t = (_seg_rest <= 10) ? make_color_rgb(235, 65, 65) : c_white;
            _draw_txt(gw / 2, _py + 14, "WAVE " + string(wave_atual) + "  |  " + (is_pt ? "TEMPO: " : "TIME: ") + string(_seg_rest) + "s  |  " + (is_pt ? "VIVOS: " : "ALIVE: ") + string(_inimigos), _cor_t);
        }
        
        // Barra de Vida do Portão do Laboratório
        var _bx = _px + 14;
        var _by = _py + 28;
        var _bw = _pw - 28;
        var _bh = 14;
        var _pct_portao = clamp(portao_hp / max(1, portao_hp_max), 0, 1);
        
        draw_set_color(make_color_rgb(30, 15, 20));
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
        draw_set_color((portao_piscar > 0) ? c_white : make_color_rgb(65, 185, 245));
        draw_rectangle(_bx, _by, _bx + (_bw * _pct_portao), _by + _bh, false);
        draw_set_color(make_color_rgb(85, 75, 60));
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
        
        _draw_txt(gw / 2, _by + 7, (is_pt ? "PORTAO DO LAB: " : "LAB GATE: ") + string(portao_hp) + " / " + string(portao_hp_max), c_white);
        _draw_txt(gw / 2, _py + 54, (is_pt ? "Defenda o Portao a Esquerda! (X=" : "Defend Left Gate! (X=") + string(portao_x) + ")", make_color_rgb(175, 180, 195));
        
        // Painel Canto Superior Direito (Score, Tempo Total e Recorde)
        var _sx = gw - 195;
        var _sy = 10;
        draw_set_color(make_color_rgb(14, 16, 22));
        draw_set_alpha(0.85);
        draw_rectangle(_sx, _sy, gw - 12, _sy + 64, false);
        draw_set_alpha(1.0);
        draw_set_color(make_color_rgb(85, 75, 60));
        draw_rectangle(_sx, _sy, gw - 12, _sy + 64, true);
        
        draw_set_halign(fa_right);
        var _t_str = _formatar_tempo(floor(tempo_sobrevivido_frames / 60));
        _draw_txt(gw - 20, _sy + 14, "SCORE: " + string(global.score_atual), _col_gold);
        _draw_txt(gw - 20, _sy + 32, (is_pt ? "DURACAO: " : "TIME: ") + _t_str, c_white);
        _draw_txt(gw - 20, _sy + 50, "TOP 1: " + string(top_scores[0]), make_color_rgb(80, 215, 105));
    }
}

// ==========================================
// 0.5 TELA DE ESCOLHA DE CARTAS (ESTILO ARENA LOL)
// ==========================================
if (variable_instance_exists(id, "escolhendo_carta") && escolhendo_carta) {
    draw_set_font(fnt_menu);
    
    draw_set_color(c_black);
    draw_set_alpha(0.88);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var col_gold = make_color_rgb(245, 195, 65);
    var col_card = make_color_rgb(20, 24, 34);
    var col_sel  = make_color_rgb(38, 46, 68);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    _draw_txt(gw / 2, 42, is_pt ? "WAVE " + string(wave_atual) + " DEFENDIDA! ESCOLHA UM BUFF:" : "WAVE " + string(wave_atual) + " CLEARED! CHOOSE A BUFF:", col_gold);
    _draw_txt(gw / 2, 68, is_pt ? "Use [A / D] ou Setas para escolher e [ENTER / ESPACO] para confirmar" : "Use [A / D] or Arrows to select and [ENTER / SPACE] to confirm", make_color_rgb(180, 185, 200));
    
    var card_w = 220;
    var card_h = 260;
    var gap    = 24;
    var total_w = (card_w * 3) + (gap * 2);
    var start_x = round((gw - total_w) / 2);
    var card_y  = 105;
    
    for (var c = 0; c < 3; c++) {
        var cx1 = start_x + c * (card_w + gap);
        var cy1 = card_y - ((carta_index == c) ? 10 : 0);
        var cx2 = cx1 + card_w;
        var cy2 = cy1 + card_h;
        
        var _dados = catalogo_cartas[cartas_opcoes[c]];
        var _cor_borda = (carta_index == c) ? _dados.cor : make_color_rgb(75, 80, 95);
        
        draw_set_color((carta_index == c) ? col_sel : col_card);
        draw_rectangle(cx1, cy1, cx2, cy2, false);
        
        draw_set_color(_dados.cor);
        draw_set_alpha((carta_index == c) ? 0.9 : 0.45);
        draw_rectangle(cx1, cy1, cx2, cy1 + 48, false);
        draw_set_alpha(1.0);
        
        draw_set_color(_cor_borda);
        draw_rectangle(cx1, cy1, cx2, cy2, true);
        if (carta_index == c) {
            draw_rectangle(cx1 + 2, cy1 + 2, cx2 - 2, cy2 - 2, true);
        }
        
        var _titulo = is_pt ? _dados.nome_pt : _dados.nome_en;
        _draw_txt((cx1 + cx2) / 2, cy1 + 24, _titulo, c_white);
        
        draw_set_color(_dados.cor);
        draw_circle((cx1 + cx2) / 2, cy1 + 100, 22, false);
        draw_set_color(c_white);
        draw_circle((cx1 + cx2) / 2, cy1 + 100, 22, true);
        _draw_txt((cx1 + cx2) / 2, cy1 + 100, "+" + string(c + 1), c_black);
        
        var _desc = is_pt ? _dados.desc_pt : _dados.desc_en;
        draw_set_color(c_black);
        draw_text_ext(round((cx1 + cx2) / 2) + 1, cy1 + 166, _desc, 20, card_w - 24);
        draw_set_color(c_white);
        draw_text_ext(round((cx1 + cx2) / 2), cy1 + 165, _desc, 20, card_w - 24);
        
        if (carta_index == c) {
            _draw_txt((cx1 + cx2) / 2, cy2 - 22, is_pt ? "[ ENTER: ESCOLHER ]" : "[ ENTER: SELECT ]", col_gold);
        }
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
    exit;
}

// ==========================================
// 1. EFEITO GLOBAL DE BRILHO NA TELA
// ==========================================
if (variable_global_exists("brilho")) {
    if (global.brilho < 0.5) {
        draw_set_color(c_black);
        draw_set_alpha((0.5 - global.brilho) * 1.4);
        draw_rectangle(0, 0, gw, gh, false);
        draw_set_alpha(1.0);
    } else if (global.brilho > 0.5) {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha((global.brilho - 0.5) * 0.6);
        draw_rectangle(0, 0, gw, gh, false);
        draw_set_alpha(1.0);
        gpu_set_blendmode(bm_normal);
    }
}

// ==========================================
// 1.5 TELA DE FIM DE JOGO + TABELA DE RECORDES DA MOSTRA (TOP 5)
// ==========================================
if (variable_instance_exists(id, "is_dead") && is_dead) {
    draw_set_font(fnt_menu);
    
    var col_bg_panel   = make_color_rgb(16, 14, 20);
    var col_header     = make_color_rgb(38, 18, 22);
    var col_border_out = make_color_rgb(120, 45, 50);
    var col_crimson    = make_color_rgb(230, 55, 65);
    var col_gold       = make_color_rgb(245, 195, 65);
    var col_highlight  = make_color_rgb(55, 25, 32);
    var col_text_off   = make_color_rgb(175, 180, 195);
    
    draw_set_color(c_black);
    draw_set_alpha(0.90 * death_alpha);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var pw = 620;
    var ph = 390;
    var px = round((gw - pw) / 2);
    var py = round((gh - ph) / 2);
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_crimson);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    draw_set_color(col_header);
    draw_rectangle(px + 3, py + 3, px + pw - 3, py + 46, false);
    draw_set_color(col_crimson);
    draw_line(px + 2, py + 46, px + pw - 2, py + 46);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _titulo_fim = "VOCE MORREU!";
    if (motivo_derrota == 2) _titulo_fim = is_pt ? "O PORTAO DO LABORATORIO FOI DESTRUIDO!" : "THE LAB GATE WAS DESTROYED!";
    if (motivo_derrota == 3) _titulo_fim = is_pt ? "TEMPO ESGOTADO (TIME OUT)!" : "TIME OUT!";
    _draw_txt(gw / 2, py + 24, _titulo_fim, col_crimson);
    
    var _duracao_str = _formatar_tempo(floor(tempo_sobrevivido_frames / 60));
    var _resumo = "SCORE FINAL: " + string(global.score_atual) +
                  "   |   TEMPO: " + _duracao_str +
                  "   |   WAVE ALCANCADA: " + string(wave_atual);
    _draw_txt(gw / 2, py + 68, _resumo, col_gold);
    
    // TABELA TOP 5 RECORDES DA MOSTRA
    var tab_x1 = px + 36;
    var tab_x2 = px + pw - 36;
    var tab_y1 = py + 94;
    
    draw_set_color(make_color_rgb(24, 28, 38));
    draw_rectangle(tab_x1, tab_y1, tab_x2, tab_y1 + 28, false);
    draw_set_color(col_gold);
    draw_rectangle(tab_x1, tab_y1, tab_x2, tab_y1 + 28, true);
    _draw_txt(gw / 2, tab_y1 + 14, is_pt ? "RANKING DA MOSTRA - TOP 5 DEFENSORES DO RATLAB" : "SHOWCASE LEADERBOARD - TOP 5 DEFENDERS", col_gold);
    
    for (var r = 0; r < 5; r++) {
        var ry = tab_y1 + 30 + (r * 30);
        var _eh_atual = (top_scores[r] == global.score_atual && global.score_atual > 0);
        
        draw_set_color(_eh_atual ? make_color_rgb(45, 55, 35) : make_color_rgb(20, 22, 30));
        draw_rectangle(tab_x1, ry, tab_x2, ry + 28, false);
        draw_set_color(col_border_out);
        draw_rectangle(tab_x1, ry, tab_x2, ry + 28, true);
        
        var _cor_linha = _eh_atual ? make_color_rgb(80, 215, 105) : ((r == 0) ? col_gold : c_white);
        
        draw_set_halign(fa_left);
        _draw_txt(tab_x1 + 16, ry + 14, "#" + string(r + 1) + "  -  " + string(top_scores[r]) + " PTS", _cor_linha);
        
        draw_set_halign(fa_center);
        _draw_txt(gw / 2 + 20, ry + 14, "WAVE " + string(top_waves[r]), _cor_linha);
        
        draw_set_halign(fa_right);
        _draw_txt(tab_x2 - 16, ry + 14, (is_pt ? "TEMPO: " : "TIME: ") + _formatar_tempo(top_tempos[r]), _cor_linha);
    }
    
    draw_set_halign(fa_center);
    var opcoes_morte = [
        is_pt ? "JOGAR NOVAMENTE (TENTAR BATER O RECORDE)" : "PLAY AGAIN (BEAT THE HIGHSCORE)",
        is_pt ? "VOLTAR AO MENU PRINCIPAL" : "RETURN TO MAIN MENU"
    ];
    
    var start_y = py + 312;
    var row_h   = 42;
    var btn_w   = 440;
    var bx1     = round((gw - btn_w) / 2);
    var bx2     = bx1 + btn_w;
    
    for (var i = 0; i < 2; i++) {
        var yy = start_y + (i * row_h);
        if (death_index == i) {
            draw_set_color(col_highlight);
            draw_rectangle(bx1, yy - 15, bx2, yy + 15, false);
            draw_set_color(col_gold);
            draw_rectangle(bx1, yy - 15, bx1 + 6, yy + 15, false);
            draw_set_color(col_crimson);
            draw_rectangle(bx1, yy - 15, bx2, yy + 15, true);
            _draw_txt(gw / 2, yy, opcoes_morte[i], c_white);
        } else {
            draw_set_color(col_header);
            draw_rectangle(bx1, yy - 15, bx2, yy + 15, false);
            draw_set_color(col_border_out);
            draw_rectangle(bx1, yy - 15, bx2, yy + 15, true);
            _draw_txt(gw / 2, yy, opcoes_morte[i], col_text_off);
        }
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
    exit;
}

// ==========================================
// 2. MENU DE PAUSA EM TELA INTEIRA
// ==========================================
if (is_paused) {
    draw_set_font(fnt_menu);
    
    var col_bg_panel   = make_color_rgb(14, 16, 22);
    var col_header     = make_color_rgb(24, 28, 38);
    var col_border_out = make_color_rgb(85, 75, 60);
    var col_gold       = make_color_rgb(245, 195, 65);
    var col_highlight  = make_color_rgb(42, 48, 66);
    var col_text_off   = make_color_rgb(175, 180, 195);
    
    draw_set_color(c_black);
    draw_set_alpha(0.90);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var pw = round(gw * 0.92);
    var ph = round(gh * 0.86);
    var px = round((gw - pw) / 2);
    var py = round((gh - ph) / 2) - 6;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    if (pause_state == 0) {
        draw_set_color(col_header);
        draw_rectangle(px + 3, py + 3, px + pw - 3, py + 44, false);
        draw_set_color(col_gold);
        draw_line(px + 2, py + 44, px + pw - 2, py + 44);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        _draw_txt(gw / 2, py + 24, is_pt ? "JOGO EM PAUSA" : "GAME PAUSED", col_gold);
        
        pause_opcoes[0] = is_pt ? "CONTINUAR JOGO" : "RESUME GAME";
        pause_opcoes[1] = is_pt ? "OPCOES E CONTROLES" : "OPTIONS & CONTROLS";
        pause_opcoes[2] = is_pt ? "SALVAR RECORDE E SAIR" : "SAVE HIGHSCORE & QUIT";
        
        var start_y = py + round(ph * 0.36);
        var row_h   = 56;
        var btn_w   = min(380, round(pw * 0.60));
        var bx1     = round((gw - btn_w) / 2);
        var bx2     = bx1 + btn_w;
        
        for (var i = 0; i < array_length(pause_opcoes); i++) {
            var yy = start_y + (i * row_h);
            
            if (pause_index == i) {
                draw_set_color(col_highlight);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, false);
                draw_set_color(col_gold);
                draw_rectangle(bx1, yy - 18, bx1 + 6, yy + 18, false);
                draw_set_color(col_border_out);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, true);
                
                _draw_txt(gw / 2, yy, pause_opcoes[i], c_white);
            } else {
                draw_set_color(col_header);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, false);
                draw_set_color(col_border_out);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, true);
                _draw_txt(gw / 2, yy, pause_opcoes[i], col_text_off);
            }
        }
    }
    else if (pause_state == 1) {
        if (!variable_instance_exists(id, "opcao_aba")) opcao_aba = 0;
        
        var tab_w = (pw - 4) / 2;
        var tab_h = 38;
        var nomes_abas = [
            is_pt ? "[Q] 1. GERAL E VIDEO" : "[Q] 1. GENERAL & VIDEO",
            is_pt ? "2. CONTROLES [E]" : "2. CONTROLS [E]"
        ];
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        for (var t = 0; t < 2; t++) {
            var tx1 = px + 2 + (t * tab_w);
            var tx2 = tx1 + tab_w;
            var ty1 = py + 2;
            var ty2 = ty1 + tab_h;
            
            if (opcao_aba == t) {
                draw_set_color(col_highlight);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_gold);
                draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
                _draw_txt((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t], c_white);
            } else {
                draw_set_color(col_header);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_border_out);
                draw_rectangle(tx1, ty1, tx2, ty2, true);
                _draw_txt((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t], col_text_off);
            }
        }
        
        var txt_sim     = is_pt ? "LIGADO" : "ON";
        var txt_nao     = is_pt ? "DESLIGADO" : "OFF";
        var txt_espera  = is_pt ? "PRESSIONE TECLA..." : "PRESS ANY KEY...";
        var val_brilho  = clamp(variable_global_exists("brilho") ? global.brilho : 0.5, 0.1, 1.0);
        var _brilho_pct = string(round(val_brilho * 100)) + "%";
        var val_vol     = clamp(variable_global_exists("vol_master") ? global.vol_master : 1.0, 0.0, 1.0);
        var _vol_pct    = string(round(val_vol * 100)) + "%";
        
        if (opcao_aba == 0) {
            if (!variable_global_exists("res_index")) global.res_index = 0;
            var _res_nomes = ["1280 x 720 (HD)", "1600 x 900 (HD+)", "1920 x 1080 (FHD)"];
            var _res_atual = _res_nomes[clamp(global.res_index, 0, 2)];
            
            var labels_aba0 = [
                is_pt ? "Volume Geral (Master)" : "Master Volume",
                is_pt ? "Idioma do Jogo" : "Game Language",
                is_pt ? "Modo Tela Cheia" : "Fullscreen Mode",
                is_pt ? "Resolucao da Janela" : "Window Resolution",
                is_pt ? "Tremor de Tela (Shake)" : "Screen Shake",
                is_pt ? "Nivel de Brilho" : "Brightness Level",
                is_pt ? "Voltar ao Menu de Pausa" : "Back to Pause Menu"
            ];
            
            var values_aba0 = [
                "< " + _vol_pct + " >",
                "< " + global.idioma + " >",
                "< " + (window_get_fullscreen() ? txt_sim : txt_nao) + " >",
                "< " + _res_atual + " >",
                "< " + (global.tremer_tela ? txt_sim : txt_nao) + " >",
                "< " + _brilho_pct + " >",
                ""
            ];
            
            var row_h = (ph - 90) / 7;
            var list_y = py + 72;
            
            for (var idx = 0; idx < array_length(labels_aba0); idx++) {
                var yy = list_y + (idx * row_h);
                var rx1 = px + 32;
                var rx2 = px + pw - 32;
                var is_sel = (pause_index == idx);
                
                if (is_sel) {
                    draw_set_color(col_highlight);
                    draw_rectangle(rx1, yy - 15, rx2, yy + 15, false);
                    draw_set_color(col_gold);
                    draw_rectangle(rx1, yy - 15, rx1 + 5, yy + 15, false);
                }
                
                draw_set_halign(fa_left);
                _draw_txt(rx1 + 16, yy, labels_aba0[idx], is_sel ? c_white : col_text_off);
                
                draw_set_halign(fa_right);
                if (idx == 0) {
                    var bar_w = 100;
                    var bar_h = 10;
                    var bar_x1 = rx2 - 80 - bar_w;
                    var bar_y1 = yy - (bar_h / 2);
                    draw_set_color(c_dkgray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);
                    draw_set_color(is_sel ? col_gold : c_gray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * val_vol), bar_y1 + bar_h, false);
                    _draw_txt(rx2 - 14, yy, values_aba0[idx], is_sel ? col_gold : c_ltgray);
                }
                else if (idx == 5) {
                    var bar_w = 100;
                    var bar_h = 10;
                    var bar_x1 = rx2 - 80 - bar_w;
                    var bar_y1 = yy - (bar_h / 2);
                    draw_set_color(c_dkgray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);
                    draw_set_color(is_sel ? col_gold : c_gray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * val_brilho), bar_y1 + bar_h, false);
                    _draw_txt(rx2 - 14, yy, values_aba0[idx], is_sel ? col_gold : c_ltgray);
                } else if (idx < 6) {
                    _draw_txt(rx2 - 14, yy, values_aba0[idx], is_sel ? col_gold : c_ltgray);
                }
            }
        }
        else if (opcao_aba == 1) {
            var labels_aba1 = [
                is_pt ? "Pular" : "Jump",
                is_pt ? "Atacar (Lanca)" : "Attack (Spear)",
                is_pt ? "Esquivar (Roll)" : "Dodge (Roll)",
                is_pt ? "Usar Curativo" : "Use Bandage",
                is_pt ? "Arremessar Item" : "Throw Item",
                is_pt ? "Mover Esquerda" : "Move Left",
                is_pt ? "Mover Direita" : "Move Right",
                is_pt ? "Voltar ao Menu de Pausa" : "Back to Pause Menu"
            ];
            
            var keys_array = [global.key_jump, global.key_attack, global.key_roll, global.key_heal, global.key_throw, global.key_left, global.key_right];
            
            var row_h = (ph - 80) / 8;
            var list_y = py + 66;
            
            for (var idx = 0; idx < array_length(labels_aba1); idx++) {
                var yy = list_y + (idx * row_h);
                var rx1 = px + 32;
                var rx2 = px + pw - 32;
                var is_sel = (pause_index == idx);
                
                if (is_sel) {
                    draw_set_color(col_highlight);
                    draw_rectangle(rx1, yy - 13, rx2, yy + 13, false);
                    draw_set_color(aguardando_tecla ? c_orange : col_gold);
                    draw_rectangle(rx1, yy - 13, rx1 + 5, yy + 13, false);
                }
                
                draw_set_halign(fa_left);
                _draw_txt(rx1 + 16, yy, labels_aba1[idx], is_sel ? c_white : col_text_off);
                
                draw_set_halign(fa_right);
                if (idx < 7) {
                    var txt_k = (aguardando_tecla && pause_index == idx) ? txt_espera : "[ " + nome_tecla(keys_array[idx]) + " ]";
                    _draw_txt(rx2 - 14, yy, txt_k, is_sel ? (aguardando_tecla ? c_orange : col_gold) : c_ltgray);
                }
            }
        }
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var dica_rodape = is_pt 
        ? "[W/S] Navegar   |   [Q/E] Aba   |   [A/D ou ENTER] Alterar   |   [ESC] Voltar" 
        : "[W/S] Navigate   |   [Q/E] Tab   |   [A/D or ENTER] Change   |   [ESC] Back";
    _draw_txt(gw / 2, gh - 15, dica_rodape, col_text_off);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}