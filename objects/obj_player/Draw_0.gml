// 1. Barra de progresso do Crafting (Em cima da cabeça)
if (state == player_state.craft) {
    var bar_w = 24;  
    var bar_h = 4;   
    var bar_x = x - (bar_w / 2);
    var bar_y = y - 24; 
    
    // Fundo da barra
    draw_set_color(c_black);
    draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);
    
    // Preenchimento branco
    var pct = craft_timer / craft_time_max;
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_w * pct), bar_y + bar_h, false);
    
    // Reseta cor para não bugar
    draw_set_color(c_white);
}

// 2. Controle do "piscar" de imunidade
var alpha_atual = 1.0;
if (is_invulnerable) {
    if ((iframe_timer mod 8) < 4) {
        alpha_atual = 0.2; // Rato fica transparente
    }
}

// 3. Desenho do personagem com Game Feel e Piscar aplicados
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    scale_x * facing, // Escala e espelhamento
    scale_y,
    image_angle,
    image_blend,
    alpha_atual       // Aplica a transparência do I-Frame
);