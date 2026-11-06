// ==========================================
// 0. SEGURANÇA DE VARIÁVEIS GLOBAIS (FALLBACK)
// ==========================================
if (!variable_global_exists("idioma"))        global.idioma      = "PT";
if (!variable_global_exists("tremer_tela"))   global.tremer_tela = 1;
if (!variable_global_exists("tela_cheia"))    global.tela_cheia  = window_get_fullscreen();
if (!variable_global_exists("key_jump"))      global.key_jump    = vk_space;
if (!variable_global_exists("key_attack"))    global.key_attack  = ord("J");
if (!variable_global_exists("key_roll"))      global.key_roll    = ord("K");
if (!variable_global_exists("key_heal"))      global.key_heal    = ord("H");
if (!variable_global_exists("key_throw"))     global.key_throw   = ord("F");
if (!variable_global_exists("key_right"))     global.key_right   = vk_right;
if (!variable_global_exists("key_left"))      global.key_left    = vk_left;

// ==========================================
// 1. ESTADOS E OPÇÕES DO MENU INICIAL
// ==========================================
menu_state = 0; // 0 = Menu Principal | 1 = Opções e Controles
aguardando_tecla = false;

options = ["new_game", "continue_game", "options", "quit"];

// Verifica se o save existe (usa a função se existir, ou checa o arquivo direto)
if (script_exists(asset_get_index("save_existe"))) {
    has_save = save_existe(1);
} else {
    has_save = file_exists("save_1.ini");
}

// Se tiver save, o cursor já começa no "Continuar" (1), senão começa em "Novo Jogo" (0)
menu_index = has_save ? 1 : 0;

// Função auxiliar para desenhar nomes legíveis das teclas
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