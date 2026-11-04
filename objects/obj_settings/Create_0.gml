// Evento Create do obj_settings (marque como Persistent)
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

global.vol_master = 1.0;
global.vol_sfx = 0.8;
global.vol_musica = 0.5;

audio_master_gain(global.vol_master);


// Função para carregar as opções ao abrir o jogo
function carregar_configuracoes() {
    ini_open("config.ini");
    
    global.idioma = ini_read_string("Geral", "Idioma", "PT");
    global.tela_cheia = ini_read_real("Video", "Fullscreen", 0);
    global.tremer_tela = ini_read_real("Video", "TremerTela", 1); // 1 é true
    
    // Volumes
    global.vol_master = ini_read_real("Audio", "Master", 1.0);
    global.vol_sfx = ini_read_real("Audio", "SFX", 0.8);
    global.vol_musica = ini_read_real("Audio", "Musica", 0.5);
    
    // Controles
    global.key_jump = ini_read_real("Controles", "Pulo", vk_space);
    global.key_attack = ini_read_real("Controles", "Ataque", ord("J"));
    global.key_roll = ini_read_real("Controles", "Esquiva", ord("K"));
    global.key_heal = ini_read_real("Controles", "Cura", ord("Q"));
    
    ini_close();
    
    // Aplica as configurações carregadas
    audio_master_gain(global.vol_master);
    window_set_fullscreen(global.tela_cheia);
}

global.key_throw = ord("F");
global.key_menu = ord("I");
global.key_up = vk_up;
global.key_down = vk_down;
global.key_confirm = vk_enter;

carregar_configuracoes();