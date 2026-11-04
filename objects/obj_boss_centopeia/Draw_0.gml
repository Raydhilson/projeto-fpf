// 1. Efeito de piscar branco ao tomar dano
if (piscar > 0) {
    gpu_set_fog(true, c_white, 0, 0);
}

// 2. Desenho da Centopeia
if (sprite_index != -1) {
    draw_self();
} else {
    // Desenho temporário da Centopeia (Corpo alongado)
    draw_set_color(image_blend);
    draw_rectangle(x - 24, y - 24, x + 24, y, false);
    
    // Olhos amarelos brilhantes do chefe
    draw_set_color(c_yellow);
    draw_rectangle(x + (12 * facing), y - 18, x + (18 * facing), y - 14, false);
    
    draw_set_color(c_white);
}

if (piscar > 0) {
    gpu_set_fog(false, c_white, 0, 0);
}

// 3. Barra de Vida do Chefe (Alinhada direto na Câmera!)
if (state != centopeia_state.subterranea) {
    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);
    var cam_w = camera_get_view_width(cam);
    
    var bar_w = 200;
    var bar_h = 8;
    var bar_x = cam_x + (cam_w / 2) - (bar_w / 2);
    var bar_y = cam_y + 24;
    
    // Borda preta
    draw_set_color(c_black);
    draw_rectangle(bar_x - 2, bar_y - 2, bar_x + bar_w + 2, bar_y + bar_h + 2, false);
    
    // Fundo cinza escuro (Corrigido para c_dkgray)
    draw_set_color(c_dkgray);
    draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);
    
    // Preenchimento roxo do HP
    var hp_pct = clamp(hp / hp_max, 0, 1);
    draw_set_color(c_purple);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_w * hp_pct), bar_y + bar_h, false);
    
    // Contorno branco e Nome
    draw_set_color(c_white);
    draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);
    
    draw_set_halign(fa_center);
    draw_text(bar_x + (bar_w / 2), bar_y - 14, "CENTOPEIA ALFA");
    draw_set_halign(fa_left);
}