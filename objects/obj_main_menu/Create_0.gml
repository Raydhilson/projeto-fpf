if (display_get_gui_width() != 800) {
    display_set_gui_size(800, 450);
}
if (!variable_global_exists("slot_atual"))    global.slot_atual    = 1;
if (!variable_global_exists("brilho"))        global.brilho        = 0.5;
if (!variable_global_exists("idioma"))        global.idioma        = "PT";
if (!variable_global_exists("tremer_tela"))   global.tremer_tela   = 1;
if (!variable_global_exists("tela_cheia"))    global.tela_cheia    = window_get_fullscreen();
if (!variable_global_exists("vol_master"))    global.vol_master    = 1.0;
if (!variable_global_exists("vol_sfx"))       global.vol_sfx       = 0.85;
if (!variable_global_exists("vol_musica"))    global.vol_musica    = 0.5;

if (!variable_global_exists("key_jump"))      global.key_jump      = vk_space;
if (!variable_global_exists("key_attack"))    global.key_attack    = ord("J");
if (!variable_global_exists("key_roll"))      global.key_roll      = ord("K");
if (!variable_global_exists("key_heal"))      global.key_heal      = ord("H");
if (!variable_global_exists("key_throw"))     global.key_throw     = ord("F");
if (!variable_global_exists("key_right"))     global.key_right     = vk_right;
if (!variable_global_exists("key_left"))      global.key_left      = vk_left;
if (!variable_global_exists("key_up"))        global.key_up        = vk_up;
if (!variable_global_exists("key_down"))      global.key_down      = vk_down;
if (!variable_global_exists("key_confirm"))   global.key_confirm   = vk_enter;
if (!variable_global_exists("key_tab_left"))  global.key_tab_left  = ord("Q");
if (!variable_global_exists("key_tab_right")) global.key_tab_right = ord("E");

menu_state = 0; // 0 = Menu Principal | 1 = Opções | 2 = Slots de Save
modo_slot  = "load"; 
slot_index = 0;      
slots_info = [obter_info_slot(1), obter_info_slot(2), obter_info_slot(3)];

opcao_aba  = 0;
aguardando_tecla = false;

options = ["new_game", "continue_game", "options", "quit"];

has_save = (save_existe(1) || save_existe(2) || save_existe(3));
menu_index = has_save ? 1 : 0;

gpu_set_tex_filter(false);

if (file_exists("config.ini")) {
    carregar_configuracoes();
}

// Garante volume ativo e toca a música do menu com segurança
audio_master_gain(global.vol_master);
var _musica_id = asset_get_index("snd_bgm_menu");
if (_musica_id != -1 && audio_exists(_musica_id)) {
    if (!audio_is_playing(_musica_id)) {
        var _inst = audio_play_sound(_musica_id, 100, true);
        audio_sound_gain(_inst, global.vol_musica, 0);
    }
}

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