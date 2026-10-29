draw_set_font(fnt_menu);
var gw = display_get_gui_width();
var gh = display_get_gui_height();

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Título do Jogo
draw_set_color(c_white);
draw_text(gw / 2, gh / 3, "TNK GAMES APRESENTA");
draw_set_color(make_color_rgb(200, 120, 50)); // Cor de ferrugem/sucata
draw_text(gw / 2, (gh / 3) + 30, "PROJETO FPF: SOBREVIVENCIA");

// Desenha as Opções
for (var i = 0; i < array_length(opcoes); i++) {
    var yy = (gh / 2) + 40 + (i * 30);
    
    if (menu_index == i) {
        draw_set_color(c_yellow);
        draw_text(gw / 2, yy, ">> " + opcoes[i] + " <<");
    } else {
        draw_set_color(c_gray);
        draw_text(gw / 2, yy, opcoes[i]);
    }
}

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_font(-1);