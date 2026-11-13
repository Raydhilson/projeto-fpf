if (aviso_timer > 0) {
    var _gw = display_get_gui_width();
    var _pt = (!variable_global_exists("idioma") || global.idioma == "PT");
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _by = 48;
    draw_set_color(make_color_rgb(18, 20, 26));
    draw_set_alpha(0.85);
    draw_rectangle((_gw / 2) - 150, _by - 18, (_gw / 2) + 150, _by + 18, false);
    draw_set_alpha(1.0);
    
    if (arena_state == 1) {
        draw_set_color(make_color_rgb(210, 45, 55));
        draw_rectangle((_gw / 2) - 150, _by - 18, (_gw / 2) + 150, _by + 18, true);
        draw_set_color(c_white);
        var _txt = _pt 
            ? "CONTENCAO ATIVA - ONDA " + string(wave_atual) + " / " + string(max_waves)
            : "LOCKDOWN ACTIVE - WAVE " + string(wave_atual) + " / " + string(max_waves);
        draw_text(_gw / 2, _by, _txt);
    } else if (arena_state == 2) {
        draw_set_color(make_color_rgb(70, 200, 95));
        draw_rectangle((_gw / 2) - 150, _by - 18, (_gw / 2) + 150, _by + 18, true);
        draw_set_text_color = c_lime;
        draw_set_color(make_color_rgb(70, 200, 95));
        var _txt = _pt ? "SETOR LIBERADO!" : "SECTOR CLEARED!";
        draw_text(_gw / 2, _by, _txt);
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}