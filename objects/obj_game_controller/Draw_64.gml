if (is_paused) {
    draw_set_font(fnt_menu);
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    // Fundo Escuro sobre o jogo parado
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    draw_set_color(c_white);
    draw_text(gw / 2, gh / 3, "--- JOGO EM PAUSA ---");
    
    for (var i = 0; i < array_length(pause_opcoes); i++) {
        var yy = (gh / 2) + (i * 40);
        if (pause_index == i) {
            draw_set_color(c_yellow);
            draw_text(gw / 2, yy, ">> " + pause_opcoes[i] + " <<");
        } else {
            draw_set_color(c_gray);
            draw_text(gw / 2, yy, pause_opcoes[i]);
        }
    }
    
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_set_font(-1);
}