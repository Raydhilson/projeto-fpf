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
    global.vol_master = ini_read_real("Audio", "Master", 1.0);
    global.tela_cheia = ini_read_real("Video", "Fullscreen", 0);
    ini_close();
    
    // Aplica as configurações carregadas
    audio_master_gain(global.vol_master);
    window_set_fullscreen(global.tela_cheia);
}

carregar_configuracoes(); // Chama a função logo ao iniciar

// Teclas padrão
global.key_jump = vk_space;
global.key_attack = ord("J");
global.key_roll = ord("K");
global.key_heal = ord("Q");

global.tremer_tela = true;