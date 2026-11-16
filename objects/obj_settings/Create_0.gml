// =====================================================================
// 1. DICIONÁRIO GLOBAL E VARIÁVEIS DE INICIALIZAÇÃO
// =====================================================================
global.idioma = "PT";
global.brilho = 0.5;

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

// Nitidez de Pixel Art e VSync (Evita piscar tela na placa de vídeo)
gpu_set_tex_filter(false);
display_reset(0, true);

// =====================================================================
// 2. FUNÇÕES GLOBAIS DE PERSISTÊNCIA (.INI) CORRIGIDAS
// =====================================================================
global.salvar_configuracoes = function() {
    ini_open("config.ini");
    ini_write_string("Geral", "Idioma", global.idioma);
    ini_write_real("Video", "Brilho", global.brilho);
    ini_write_real("Video", "Fullscreen", global.tela_cheia);
    ini_write_real("Video", "TremerTela", global.tremer_tela);
    ini_write_real("Audio", "Master", global.vol_master);
    
    // Salva rebinds de teclas
    ini_write_real("Controles", "Jump", global.key_jump);
    ini_write_real("Controles", "Attack", global.key_attack);
    ini_write_real("Controles", "Roll", global.key_roll);
    ini_write_real("Controles", "Heal", global.key_heal);
    ini_write_real("Controles", "Throw", global.key_throw);
    ini_close();
};

global.carregar_configuracoes = function() {
    if (file_exists("config.ini")) {
        ini_open("config.ini");
        global.idioma      = ini_read_string("Geral", "Idioma", "PT");
        global.brilho      = ini_read_real("Video", "Brilho", 0.5);
        global.tela_cheia  = ini_read_real("Video", "Fullscreen", 0);
        global.tremer_tela = ini_read_real("Video", "TremerTela", 1);
        global.vol_master  = ini_read_real("Audio", "Master", 1.0);
        
        // Carrega rebinds salvos
        global.key_jump   = ini_read_real("Controles", "Jump", vk_space);
        global.key_attack = ini_read_real("Controles", "Attack", ord("J"));
        global.key_roll   = ini_read_real("Controles", "Roll", ord("K"));
        global.key_heal   = ini_read_real("Controles", "Health", ord("H"));
        global.key_throw  = ini_read_real("Controles", "Throw", ord("F"));
        ini_close();
        
        // Aplica o estado de tela cheia e volume imediatamente
        window_set_fullscreen(global.tela_cheia);
        audio_master_gain(global.vol_master);
    }
};

// =====================================================================
// 3. EXECUÇÃO E TRANSIÇÃO INICIAL
// =====================================================================
global.carregar_configuracoes();
room_goto(rm_main_menu);