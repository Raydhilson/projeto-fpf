if (sprite_index != -1 && sprite_exists(sprite_index)) {
    draw_self();
} else {
    // Gota de ácido brilhante (verde-limão com núcleo amarelo)
    draw_set_color(c_lime);
    draw_circle(x, y, 5, false);
    draw_set_color(c_yellow);
    draw_circle(x - 1, y - 1, 2, false);
    draw_set_color(c_white);
}