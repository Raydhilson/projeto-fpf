// =======================================================
// --- 1. HUD DE SOBREVIVÊNCIA (Sempre visível no jogo) ---
// =======================================================
var gui_x = 32;
var gui_y = 32;

// Barra de HP
var bar_width = 150;
var bar_height = 14;

draw_set_color(c_dkgray);
draw_rectangle(gui_x, gui_y, gui_x + bar_width, gui_y + bar_height, false);

var hp_pct = clamp(hp / hp_max, 0, 1);
draw_set_color(c_red);
draw_rectangle(gui_x, gui_y, gui_x + (bar_width * hp_pct), gui_y + bar_height, false);

draw_set_color(c_white);
draw_rectangle(gui_x, gui_y, gui_x + bar_width, gui_y + bar_height, true);

// Barra de Stamina
var stam_y = gui_y + 20; 
var stam_height = 10;

draw_set_color(c_dkgray);
draw_rectangle(gui_x, stam_y, gui_x + bar_width, stam_y + stam_height, false);

var stam_pct = clamp(stamina_current / stamina_max, 0, 1);
if (stamina_exhausted) {
    draw_set_color(c_orange);
} else {
    draw_set_color(c_lime);
}

draw_rectangle(gui_x, stam_y, gui_x + (bar_width * stam_pct), stam_y + stam_height, false);

draw_set_color(c_white);
draw_rectangle(gui_x, stam_y, gui_x + bar_width, stam_y + stam_height, true);

// Contador de Sucatas
var scrap_y = stam_y + 18;
draw_set_color(make_color_rgb(200, 120, 50));
draw_circle(gui_x + 6, scrap_y + 6, 5, false);

draw_set_color(c_white);
draw_text(gui_x + 16, scrap_y - 2, "x " + string(global.scrap));


// =======================================================
// --- 2. HUB DO PERSONAGEM (Menu de Abas Pausado) ---
// =======================================================
if (state == player_state.menu) {
    
    // ATENÇÃO: Aplica a fonte que você criou (fnt_menu)
    // Se ainda não criou na pasta Fonts, comente a linha abaixo.
    draw_set_font(fnt_menu);
    
    // Pega o tamanho do seu ecrã
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    // Fundo Escurecido
    draw_set_color(c_black);
    draw_set_alpha(0.85); // 85% escuro para dar destaque às letras
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0); 
    
    // Cabeçalho das Abas
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    for (var i = 0; i < 3; i++) {
        var xx = (gw / 4) * (i + 1); 
        var yy = 20; // Ajustado mais para o topo
        
        if (aba_atual == i) {
            draw_set_color(c_yellow); 
            draw_text(xx, yy, ">> " + nome_abas[i] + " <<");
        } else {
            draw_set_color(c_gray);   
            draw_text(xx, yy, nome_abas[i]);
        }
    }
    
    // Conteúdo da Aba Selecionada
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var margem_x = 40;
    var margem_y = 60;
    
    if (aba_atual == 0) {
        // --- ABA 0: INVENTÁRIO ---
        draw_set_color(c_white);
        draw_text(margem_x, margem_y, "--- INVENTARIO DA MOCHILA ---");
        draw_text(margem_x, margem_y + 30, "SUCATA COLETADA: " + string(global.scrap));
        draw_text(margem_x, margem_y + 50, "CURATIVOS (Q): " + string(curativo_count));
        draw_text(margem_x, margem_y + 70, "MOLOTOVS  (F): " + string(molotov_count));
        draw_text(margem_x, margem_y + 110, "HP DO RATO: " + string(hp) + " / " + string(hp_max));
    }
    else if (aba_atual == 1) {
        // --- ABA 1: CRAFTING ---
        draw_set_color(c_white);
        draw_text(margem_x, margem_y, "--- MESA DE MONTAGEM ---");
        draw_text(margem_x, margem_y + 20, "Suas Sucatas: " + string(global.scrap));
        
        for (var j = 0; j < array_length(craft_recipes); j++) {
            var yy = margem_y + 60 + (j * 20); // Espaçamento mais curto para telas pequenas
            if (menu_index == j) {
                draw_set_color(c_yellow);
                draw_text(margem_x, yy, "-> " + craft_recipes[j] + " (Custo: " + string(craft_cost_array[j]) + ")");
            } else {
                draw_set_color(c_white);
                draw_text(margem_x, yy, craft_recipes[j] + " (Custo: " + string(craft_cost_array[j]) + ")");
            }
        }
    }
    else if (aba_atual == 2) {
        // --- ABA 2: MAESTRIA ---
        draw_set_color(c_white);
        draw_text(margem_x, margem_y, "--- ARMA: LANCA DE PREGO ---");
        draw_text(margem_x, margem_y + 20, "NIVEL ATUAL: " + string(arma_nivel));
        draw_text(margem_x, margem_y + 40, "XP PARA PROXIMO NIVEL: " + string(arma_xp) + " / " + string(arma_xp_max));
        
        draw_set_color(arma_nivel >= 1 ? c_white : c_gray);
        draw_text(margem_x, margem_y + 80, "NV 1: Estocada Rapida (Ataque base)");
        
        draw_set_color(arma_nivel >= 2 ? c_yellow : c_dkgray);
        draw_text(margem_x, margem_y + 100, "NV 2: Avanco Duplo (Aperte J duas vezes)");
        
        draw_set_color(arma_nivel >= 3 ? c_yellow : c_dkgray);
        draw_text(margem_x, margem_y + 120, "NV 3: Furia da Sucata (Bloqueado)");
    }
    
    // Reseta o alinhamento e a fonte para não bugar o HUD nos próximos frames
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_set_font(-1); 
}