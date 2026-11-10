// ==========================================
// 0. VERIFICAÇÃO DE ESTADO INICIAL
// ==========================================
// Se estiver escondida debaixo da terra, não desenha o corpo nem a barra
if (state == centopeia_state.subterranea) {
    exit;
}

// ==========================================
// 1. DESENHO DO CORPO OU AVISO DE BOTE
// ==========================================
// Se estiver EMERGINDO, desenha um aviso visual piscando no chão onde ela vai atacar!
if (state == centopeia_state.emergindo) {
    if ((action_timer div 4) mod 2 == 0) {
        draw_set_color(c_orange);
    } else {
        draw_set_color(c_red);
    }
    draw_rectangle(alvo_x - 24, alvo_y - 6, alvo_x + 24, alvo_y + 2, false);
    draw_set_color(c_white);
} else {
    // A. Efeito de piscar branco ao tomar dano
    if (piscar > 0) {
        gpu_set_fog(true, c_white, 0, 1);
    }

    // B. Desenho da Centopeia (Sprite real ou retângulos procedurais temporários)
    if (sprite_index != -1 && sprite_exists(sprite_index)) {
        draw_self();
    } else {
        // Corpo alongado
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
    
    // C. EFEITO VISUAL DE EXAUSTÃO (Fumaça / Suor quando cansada)
    if (state == centopeia_state.recuperando) {
        var tempo_anim = current_time / 100;
        
        for (var i = 0; i < 3; i++) {
            var offset_x = (i * 12) - 12;
            var offset_y = -22 - ((tempo_anim + (i * 2)) mod 20);
            var alpha = 1 - (((tempo_anim + (i * 2)) mod 20) / 20);
            
            draw_set_alpha(alpha);
            draw_set_color(c_ltgray);
            draw_circle(x + offset_x, y + offset_y, 3, false);
            draw_set_alpha(1.0); // Restaura o alpha normal
        }
    }
}

// ==========================================
// 2. BARRA DE VIDA DO CHEFE (HUD DA CÂMERA)
// ==========================================
var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");
var nome_boss = is_pt ? "CENTOPEIA ALFA" : "ALPHA CENTIPEDE";

var cam = view_camera[0];
var cam_x = camera_get_view_x(cam);
var cam_y = camera_get_view_y(cam);
var cam_w = camera_get_view_width(cam);

var bar_w = 200;
var bar_h = 8;
var bar_x = cam_x + (cam_w / 2) - (bar_w / 2);
var bar_y = cam_y + 24;

// Borda preta de fundo
draw_set_color(c_black);
draw_rectangle(bar_x - 2, bar_y - 2, bar_x + bar_w + 2, bar_y + bar_h + 2, false);

// Fundo cinza escuro
draw_set_color(c_dkgray);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);

// Preenchimento roxo do HP
var hp_pct = clamp(hp / hp_max, 0, 1);
draw_set_color(c_purple);
draw_rectangle(bar_x, bar_y, bar_x + (bar_w * hp_pct), bar_y + bar_h, false);

// Contorno branco e Nome do Chefe
draw_set_color(c_white);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

draw_set_halign(fa_center);
draw_text(bar_x + (bar_w / 2), bar_y - 14, nome_boss);
draw_set_halign(fa_left);