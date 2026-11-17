// =====================================================================
// 1. DICIONÁRIO GLOBAL E VARIÁVEIS DE INICIALIZAÇÃO
// =====================================================================
global.idioma = "PT";
global.brilho = 0.5;

global.textos = {
    PT: {
        jogar: "Jogar",
        opcoes: "Opcoes",
        sair: "Sair",
        morte: "VOCE MORREU"
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
global.res_index   = 0; // 0 = 1280x720 | 1 = 1600x900 | 2 = 1920x1080
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

// Nitidez de Pixel Art e VSync
gpu_set_tex_filter(false);
display_reset(0, true);
display_set_gui_size(800, 450);

// =====================================================================
// 2. EXECUÇÃO E TRANSIÇÃO INICIAL (USA AS FUNÇÕES DO SCRIPT DE SAVE)
// =====================================================================
carregar_configuracoes();
room_goto(rm_main_menu);