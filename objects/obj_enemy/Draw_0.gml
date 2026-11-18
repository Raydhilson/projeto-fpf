if (piscar > 0) {
    gpu_set_fog(true, c_white, 0, 1);
    draw_self();
    gpu_set_fog(false, c_white, 0, 0);
} else {
    draw_self();
}

// Barra de vida em cima do inimigo
if (variable_instance_exists(id, "hp_max") && hp < hp_max && hp > 0) {
    var _bw = 32;
    var _bh = 4;
    var _bx = x - (_bw / 2);
    var _by = bbox_top - 10;
    draw_set_color(c_black);
    draw_rectangle(_bx - 1, _by - 1, _bx + _bw + 1, _by + _bh + 1, false);
    draw_set_color(make_color_rgb(230, 55, 65));
    draw_rectangle(_bx, _by, _bx + (_bw * clamp(hp / hp_max, 0, 1)), _by + _bh, false);
    draw_set_color(c_white);
}