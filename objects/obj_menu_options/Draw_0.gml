draw_set_font(fnt_menu);
var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");

var col_bg_panel   = make_color_rgb(18, 20, 26);
var col_border_out = make_color_rgb(90, 80, 65);
var col_gold       = make_color_rgb(235, 185, 60);
var col_highlight  = make_color_rgb(45, 50, 65);
var col_text_off   = make_color_rgb(150, 155, 165);

var pw = 420;
var ph = 250;
var px = (room_width - pw) / 2;
var py = (room_height - ph) / 2;

draw_set_color(col_bg_panel);
draw_rectangle(px, py, px + pw, py + ph, false);
draw_set_color(col_border_out);
draw_rectangle(px, py, px + pw, py + ph, true);
draw_set_color(col_gold);
draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(room_width / 2, py + 24, is_pt ? "CONFIGURACOES" : "SETTINGS");

var start_y = py + 65;
var espacamento = 36;

for (var i = 0; i < array_length(opcoes); i++) {
    var nome_opcao = opcoes[i];
    var texto_exibir = "";
    var valor_exibir = "";
    
    switch (nome_opcao) {
        case "volume_master":
            texto_exibir = is_pt ? "Volume Geral" : "Master Volume";
            valor_exibir = "< " + string(round(global.vol_master * 100)) + "% >";
            break;
        case "tela_cheia":
            texto_exibir = is_pt ? "Tela Cheia" : "Fullscreen";
            valor_exibir = "< " + (global.tela_cheia ? "ON" : "OFF") + " >";
            break;
        case "tremer_tela":
            texto_exibir = is_pt ? "Tremer Tela" : "Screen Shake";
            valor_exibir = "< " + (global.tremer_tela ? "ON" : "OFF") + " >";
            break;
        case "idioma":
            texto_exibir = is_pt ? "Idioma" : "Language";
            valor_exibir = "< " + global.idioma + " >";
            break;
        case "voltar":
            texto_exibir = global.textos[$ global.idioma][$ "sair"];
            valor_exibir = "";
            break;
    }
    
    var yy  = start_y + (i * espacamento);
    var rx1 = px + 22;
    var rx2 = px + pw - 22;
    var is_sel = (i == menu_index);
    
    if (is_sel) {
        draw_set_color(col_highlight);
        draw_rectangle(rx1, yy - 14, rx2, yy + 14, false);
        draw_set_color(col_gold);
        draw_rectangle(rx1, yy - 14, rx1 + 4, yy + 14, false);
    }
    
    if (valor_exibir != "") {
        draw_set_halign(fa_left);
        draw_set_color(is_sel ? c_white : col_text_off);
        draw_text(rx1 + 14, yy, texto_exibir);
        
        draw_set_halign(fa_right);
        draw_set_color(is_sel ? col_gold : c_ltgray);
        draw_text(rx2 - 12, yy, valor_exibir);
    } else {
        draw_set_halign(fa_center);
        draw_set_color(is_sel ? col_gold : col_text_off);
        draw_text(room_width / 2, yy + 6, texto_exibir);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);