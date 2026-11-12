// 1. Barra de progresso do Crafting estilizada (Em cima da cabeça)
if (state == player_state.craft) {
    var bar_w = 34;  
    var bar_h = 6;   
    var bar_x = x - (bar_w / 2);
    var bar_y = y - 28; 
    var pct   = clamp(craft_timer / craft_time_max, 0, 1);
    
    // Fundo escuro e borda
    draw_set_color(make_color_rgb(18, 20, 26));
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1, false);
    
    // Preenchimento dourado
    draw_set_color(make_color_rgb(235, 185, 60));
    draw_rectangle(bar_x, bar_y, bar_x + (bar_w * pct), bar_y + bar_h, false);
    
    // Moldura externa
    draw_set_color(c_white);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1, true);
}

// 2. Controle do "piscar": SÓ PISCA SE TOMOU DANO, NUNCA NO ROLAMENTO
var alpha_atual = 1.0;
if (is_invulnerable && state != player_state.roll) {
    if ((iframe_timer mod 8) < 4) {
        alpha_atual = 0.2; 
    }
}

// 3. Desenho do personagem
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    scale_x * facing, 
    scale_y,
    image_angle,
    image_blend,
    alpha_atual       
);