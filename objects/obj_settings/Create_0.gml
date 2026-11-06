// =====================================================================
// 1. DICIONÁRIO GLOBAL E VARIÁVEIS DE INICIALIZAÇÃO
// =====================================================================
global.idioma = "PT";

global.textos = {
    PT: {
        jogar: "Jogar",
        opcoes: "Opções",
        sair: "Sair",
        morte: "VOCÊ MORREU"
    },
    EN: {
        jogar: "Play",
        opcoes: "Options",
        sair: "Quit",
        morte: "YOU DIED"
    }
};

// Vídeo e Áudio Padrão
global.tela_cheia  = 0;
global.tremer_tela = 1;
global.vol_master  = 1.0;
global.vol_sfx     = 0.8;
global.vol_musica  = 0.5;

// Controles Padrão
global.key_right     = vk_right;
global.key_left      = vk_left;
global.key_up        = vk_up;
global.key_down      = vk_down;

global.key_jump      = vk_space;
global.key_attack    = ord("J");
global.key_roll      = ord("K");
global.key_heal      = ord("H");
global.key_throw     = ord("F");

global.key_menu      = ord("I");
global.key_confirm   = vk_enter;
global.key_tab_left  = ord("Q");
global.key_tab_right = ord("E");

// =====================================================================
// 2. FUNÇÕES GLOBAIS DE PERSISTÊNCIA (.INI)
// Declaradas com global. para funcionarem em qualquer sala ou objeto!
// =======================================================
global.carregar_configuracoes = function() {
    ini_open("config.ini");
    
    global.idioma      = ini_read_string("Geral", "Idioma", "PT");
    global.tela_cheia  = ini_read_real("Video", "Fullscreen", 0);
    global.tremer_tela = ini_read_real("Video", "TremerTela", 1);
    
    global.vol_master  = ini_read_real("Audio", "Master", 1.0);
    global.vol_sfx     = ini_read_real("Audio", "SFX", 0.8);
    global.vol_musica  = ini_read_real("Audio", "Musica", 0.5);
    
    global.key_right     = ini_read_real("Controles", "Direita", vk_right);
    global.key_left      = ini_read_real("Controles", "Esquerda", vk_left);
    global.key_up        = ini_read_real("Controles", "Cima", vk_up);
    global.key_down      = ini_read_real("Controles", "Baixo", vk_down);
    
    global.key_jump      = ini_read_real("Controles", "Pulo", vk_space);
    global.key_attack    = ini_read_real("Controles", "Ataque", ord("J"));
    global.key_roll      = ini_read_real("Controles", "Esquiva", ord("K"));
    global.key_heal      = ini_read_real("Controles", "Cura", ord("H"));
    global.key_throw     = ini_read_real("Controles", "Arremesso", ord("F"));
    
    global.key_menu      = ini_read_real("Controles", "Menu", ord("I"));
    global.key_confirm   = ini_read_real("Controles", "Confirmar", vk_enter);
    global.key_tab_left  = ini_read_real("Controles", "AbaEsq", ord("Q"));
    global.key_tab_right = ini_read_real("Controles", "AbaDir", ord("E"));
    
    ini_close();
    
    audio_master_gain(global.vol_master);
    window_set_fullscreen(global.tela_cheia);
};

global.salvar_configuracoes = function() {
    ini_open("config.ini");
    
    ini_write_string("Geral", "Idioma", global.idioma);
    ini_write_real("Video", "Fullscreen", global.tela_cheia);
    ini_write_real("Video", "TremerTela", global.tremer_tela);
    
    ini_write_real("Audio", "Master", global.vol_master);
    ini_write_real("Audio", "SFX", global.vol_sfx);
    ini_write_real("Audio", "Musica", global.vol_musica);
    
    ini_write_real("Controles", "Direita", global.key_right);
    ini_write_real("Controles", "Esquerda", global.key_left);
    ini_write_real("Controles", "Cima", global.key_up);
    ini_write_real("Controles", "Baixo", global.key_down);
    
    ini_write_real("Controles", "Pulo", global.key_jump);
    ini_write_real("Controles", "Ataque", global.key_attack);
    ini_write_real("Controles", "Esquiva", global.key_roll);
    ini_write_real("Controles", "Cura", global.key_heal);
    ini_write_real("Controles", "Arremesso", global.key_throw);
    
    ini_write_real("Controles", "Menu", global.key_menu);
    ini_write_real("Controles", "Confirmar", global.key_confirm);
    ini_write_real("Controles", "AbaEsq", global.key_tab_left);
    ini_write_real("Controles", "AbaDir", global.key_tab_right);
    
    ini_close();
    show_debug_message("Configuracoes e teclas salvas no config.ini!");
};

// =====================================================================
// 3. EXECUÇÃO E TRANSIÇÃO INICIAL
// =====================================================================
global.carregar_configuracoes();
room_goto(rm_main_menu);