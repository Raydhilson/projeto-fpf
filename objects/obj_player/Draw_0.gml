// 1. Barra de progresso do Crafting estilizada (Em cima da cabeça)
if (state == player_state.craft) {
    var bar_w = 34;  
    var bar_h = 6;   
    var bar_x = x - (bar_w / 2);
    var bar_y = y - 28; 
    var pct   = clamp(craft_timer / craft_time_max, 0, 1);
    
    draw_set_color(make_color_rgb(18, 20, 26));
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1, false);
    
    draw_set_color(make_color_rgb(235, 185, 60));
    draw_rectangle(bar_x, bar_y, bar_x + (bar_w * pct), bar_y + bar_h, false);
    
    draw_set_color(c_white);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1, true);
}

// 1.5 Barra e Aviso de REVIVER no Co-op (Quando estiver nocauteado)
if (state == player_state.downed) {
    var bar_w = 38;
    var bar_h = 5;
    var bar_x = x - (bar_w / 2);
    var bar_y = y - 24;
    var pct   = clamp(revive_timer / revive_time_max, 0, 1);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_red);
    draw_text_transformed(x, bar_y - 2, "SOCORRO! [CURA]", 0.5, 0.5, 0);
    
    draw_set_color(make_color_rgb(18, 20, 26));
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1, false);
    draw_set_color(c_lime);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_w * pct), bar_y + bar_h, false);
    draw_set_color(c_white);
    draw_rectangle(bar_x - 1, bar_y - 1, bar_x + bar_w + 1, bar_y + bar_h + 1, true);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
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