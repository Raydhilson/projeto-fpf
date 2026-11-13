// ==========================================
// 0. DECLARAÇÃO OBRIGATÓRIA DE PAUSE E CÂMERA
// ==========================================
is_paused = false;
pause_state = 0; // 0 = Pause Principal | 1 = Opções e Controles
pause_index = 0;
aguardando_tecla = false;
hitstop_timer = 0;
shake_magnitude = 0;
shake_fade = 0.4;

pause_opcoes = ["CONTINUAR", "OPCOES / CONTROLES", "VOLTAR AO MENU INICIAL"];

// ==========================================
// 1. SEGURANÇA DE VARIÁVEIS GLOBAIS (FALLBACK)
// ==========================================
if (!variable_global_exists("resolucoes")) {
    global.resolucoes = [
        { w: 1280, h: 720,  label: "1280x720" },
        { w: 1366, h: 768,  label: "1366x768" },
        { w: 1600, h: 900,  label: "1600x900" },
        { w: 1920, h: 1080, label: "1920x1080" },
        { w: 2560, h: 1440, label: "2560x1440" }
    ];
}
if (!variable_global_exists("res_index"))    global.res_index    = 0;
if (!variable_global_exists("brilho"))       global.brilho       = 0.5;
if (!variable_global_exists("idioma"))       global.idioma       = "PT";
if (!variable_global_exists("tremer_tela"))  global.tremer_tela  = 1;
if (!variable_global_exists("tela_cheia"))   global.tela_cheia   = window_get_fullscreen();
if (!variable_global_exists("key_jump"))     global.key_jump     = vk_space;
if (!variable_global_exists("key_attack"))   global.key_attack   = ord("J");
if (!variable_global_exists("key_roll"))     global.key_roll     = ord("K");
if (!variable_global_exists("key_heal"))     global.key_heal     = ord("H");
if (!variable_global_exists("key_throw"))    global.key_throw    = ord("F");
if (!variable_global_exists("key_right"))    global.key_right    = vk_right;
if (!variable_global_exists("key_left"))     global.key_left     = vk_left;
if (!variable_global_exists("key_up"))       global.key_up       = vk_up;
if (!variable_global_exists("key_down"))     global.key_down     = vk_down;
if (!variable_global_exists("key_confirm"))  global.key_confirm  = vk_enter;

gpu_set_tex_filter(false);

// Defina as constantes de resolução base no topo ou antes da função
#macro CAM_W 480
#macro CAM_H 270
#macro GUI_W 960
#macro GUI_H 540

aplicar_resolucao = function() {
    var _res = global.resolucoes[global.res_index];
    window_set_fullscreen(global.tela_cheia);
    
    if (!global.tela_cheia) {
        window_set_size(_res.w, _res.h);
        alarm[0] = 1; // Centraliza a janela no próximo frame
    }
    
    // Mantém a textura interna do jogo cravada em 480x270 (Pixel Art puro)
    surface_resize(application_surface, CAM_W, CAM_H);
    
    // Mantém a camada do Menu (Draw GUI) em 960x540 (2x) para caber o painel de 540x340
    display_set_gui_size(GUI_W, GUI_H);
};

if (file_exists("config.ini")) {
    carregar_configuracoes();
}

aplicar_resolucao();

nome_tecla = function(_k) {
    var _pt = (global.idioma == "PT");
    switch (_k) {
        case vk_space:     return _pt ? "ESPACO" : "SPACE";
        case vk_up:        return _pt ? "SETA CIMA" : "UP ARROW";
        case vk_down:      return _pt ? "SETA BAIXO" : "DOWN ARROW";
        case vk_left:      return _pt ? "SETA ESQ" : "LEFT ARROW";
        case vk_right:     return _pt ? "SETA DIR" : "RIGHT ARROW";
        case vk_enter:     return "ENTER";
        case vk_shift:     return "SHIFT";
        case vk_control:   return "CTRL";
        case vk_alt:       return "ALT";
        case vk_tab:       return "TAB";
        case vk_backspace: return "BACKSPACE";
        default:
            if (_k >= 48 && _k <= 90) return chr(_k);
            return "KEY " + string(_k);
    }
};