var _cor = c_white;

switch (tipo_item) {
    case 0: _cor = make_color_rgb(210, 50, 60);   break; // Vermelho (Carne)
    case 1: _cor = make_color_rgb(50, 205, 120);  break; // Verde (Glândula)
    case 2: _cor = make_color_rgb(240, 200, 50);  break; // Amarelo (Ferrão)
}

// Desenha uma sombrinha simples no chão
draw_set_color(c_black);
draw_set_alpha(0.4);
draw_ellipse(x - 5, y - 2, x + 5, y + 2, false);
draw_set_alpha(1.0);

// Desenha o item provisório (um losango brilhante)
draw_set_color(_cor);
draw_rectangle(x - 4, y - 6, x + 4, y + 2, false);
draw_set_color(c_white);
draw_rectangle(x - 2, y - 4, x + 2, y, false);