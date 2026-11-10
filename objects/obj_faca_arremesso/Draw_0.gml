if (sprite_index != -1 && sprite_exists(sprite_index)) {
    draw_self();
} else {
    var dir = (hspd >= 0) ? 1 : -1;
    // Lâmina / Ferrão afiado
    draw_set_color(c_ltgray);
    draw_triangle(x - (6 * dir), y - 3, x - (6 * dir), y + 3, x + (10 * dir), y, false);
    // Cabo
    draw_set_color(c_maroon);
    draw_rectangle(x - (10 * dir), y - 2, x - (6 * dir), y + 2, false);
    draw_set_color(c_white);
}