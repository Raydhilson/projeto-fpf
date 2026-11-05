draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_menu); // Usando a sua fonte personalizada do menu antigo

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// ==========================================
// DESENHA O TÍTULO DO JOGO (TNK GAMES)
// ==========================================
draw_set_color(c_white);
draw_text(_gw / 2, _gh / 3, "TNK GAMES APRESENTA");

draw_set_color(make_color_rgb(200, 120, 50)); // Cor de ferrugem/sucata
draw_text(_gw / 2, (_gh / 3) + 30, "PROJETO FPF: SOBREVIVENCIA");

// ==========================================
// DESENHA AS OPÇÕES DO MENU
// ==========================================
var _spacing = 40; // Distância entre cada botão

for (var i = 0; i < array_length(options); i++) {
    var _option = options[i];
    var _text = "";
    
    // Define o texto com base no idioma atual
    switch (_option) {
        case "new_game": 
            _text = (global.idioma == "PT") ? "Novo Jogo" : "New Game"; 
            break;
        case "continue_game": 
            _text = (global.idioma == "PT") ? "Continuar" : "Continue"; 
            break;
        case "options": 
            _text = (global.idioma == "PT") ? "Opções" : "Options"; 
            break;
        case "quit": 
            _text = (global.idioma == "PT") ? "Sair" : "Quit"; 
            break;
    }
    
    var _yy = (_gh / 2) + 40 + (i * _spacing);
    
    // Controle de Cores e Seleção
    if (_option == "continue_game" && !has_save) {
        // Sem save: botão cinza escuro
        draw_set_color(c_dkgray);
        draw_text(_gw / 2, _yy, _text);
    } else if (i == menu_index) {
        // Opção selecionada: Amarelo e com setas
        draw_set_color(c_yellow);
        draw_text(_gw / 2, _yy, ">> " + _text + " <<");
    } else {
        // Opção normal: Cinza
        draw_set_color(c_gray);
        draw_text(_gw / 2, _yy, _text);
    }
}

// Reseta o alinhamento para não bugar outros textos do jogo
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_font(-1);