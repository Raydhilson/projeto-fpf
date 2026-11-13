if (arena_state == 1) {
    var _x_esq = x - arena_half_w;
    var _x_dir = x + arena_half_w - 16;
    var _y_top = y - arena_height;
    
    // Desenha os feixes de contenção industrial nas duas bordas
    draw_set_color(make_color_rgb(220, 40, 55));
    draw_set_alpha(0.75 + sin(current_time / 80) * 0.2);
    
    draw_rectangle(_x_esq, _y_top, _x_esq + 12, y, false);
    draw_rectangle(_x_dir, _y_top, _x_dir + 12, y, false);
    
    draw_set_color(c_yellow);
    draw_rectangle(_x_esq, _y_top, _x_esq + 12, y, true);
    draw_rectangle(_x_dir, _y_top, _x_dir + 12, y, true);
    
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}