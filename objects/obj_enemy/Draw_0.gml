// Se estiver tomando dano, pinta tudo de branco sólido
if (piscar > 0) {
    gpu_set_fog(true, c_white, 0, 0); 
}

// Se tiver um sprite atribuído, desenha-o
if (sprite_index != -1) {
    draw_self();
} else {
    // Desenho temporário do inimigo
    draw_set_color(image_blend);
    draw_rectangle(x - 16, y - 32, x + 16, y, false);
    
    // Desenha um "olho" para saberes para onde ele está a olhar
    draw_set_color(c_black);
    draw_rectangle(x + (8 * facing), y - 24, x + (12 * facing), y - 20, false);
    
    draw_set_color(c_white);
}

// Tira a tinta branca após desenhar
if (piscar > 0) {
    gpu_set_fog(false, c_white, 0, 0); 
}