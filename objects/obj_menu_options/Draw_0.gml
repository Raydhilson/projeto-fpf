draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(-1); // Substitua por sua fonte, se tiver uma

var xx = room_width / 2;
var yy = room_height / 2 - 60;
var espacamento = 30;

for (var i = 0; i < array_length(opcoes); i++) {
    var nome_opcao = opcoes[i];
    var texto_exibir = "";
    var valor_exibir = "";
    
    // Define os textos baseados na variável global
    switch (nome_opcao) {
        case "volume_master":
            texto_exibir = (global.idioma == "PT") ? "Volume Geral" : "Master Volume";
            valor_exibir = string(round(global.vol_master * 100)) + "%";
            break;
        case "tela_cheia":
            texto_exibir = (global.idioma == "PT") ? "Tela Cheia" : "Fullscreen";
            valor_exibir = global.tela_cheia ? "ON" : "OFF";
            break;
        case "tremer_tela":
            texto_exibir = (global.idioma == "PT") ? "Tremer Tela" : "Screen Shake";
            valor_exibir = global.tremer_tela ? "ON" : "OFF";
            break;
        case "idioma":
            texto_exibir = (global.idioma == "PT") ? "Idioma" : "Language";
            valor_exibir = global.idioma;
            break;
        case "voltar":
            texto_exibir = global.textos[$ global.idioma][$ "sair"]; // Puxa direto do dicionário do obj_settings
            valor_exibir = "";
            break;
    }
    
    // Destaca a opção atual em amarelo
    if (i == menu_index) {
        draw_set_color(c_yellow);
        texto_exibir = "> " + texto_exibir + " <";
    } else {
        draw_set_color(c_white);
    }
    
    // Desenha o nome da opção e o seu valor
    if (valor_exibir != "") {
        draw_text(xx, yy + (i * espacamento), texto_exibir + ": " + valor_exibir);
    } else {
        draw_text(xx, yy + (i * espacamento), texto_exibir);
    }
}