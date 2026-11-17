if (alpha > 0) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    draw_set_color(c_black);
    draw_set_alpha(alpha);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0); // Reseta o alpha padrão
}