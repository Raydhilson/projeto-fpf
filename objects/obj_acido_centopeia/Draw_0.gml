if (sprite_index != -1) {
    draw_self();
} else {
    // Desenho provisório: Gota de ácido verde brilhante com núcleo amarelo
    draw_set_color(c_lime);
    draw_circle(x, y, 5, false);
    draw_set_color(c_yellow);
    draw_circle(x - 1, y - 1, 2, false);
    draw_set_color(c_white);
}