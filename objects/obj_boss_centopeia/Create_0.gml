// --- ATRIBUTOS DO CHEFE ---
hp_max = 50;
hp = hp_max;
hspd = 0;
vspd = 0;
grv = 0.3;
facing = -1;

// --- ESTADOS DA CENTOPEIA (COM TELEGRAFIA E EXAUSTÃO) ---
enum centopeia_state {
    subterranea,     // Escondida
    emergindo,       // Saindo do chão
    patrulha_luta,   // Andando e escolhendo ataque
    preparando_bote, // NOVO: Aviso antes da investida (Telegraph)
    investida,       // Bote rápido corpo a corpo
    recuperando,     // NOVO: Janela de cansaço após ataques (Abertura para Kite!)
    cuspindo,        // Ataque de projéteis de ácido
    cavando   ,
	mordida// Voltando para a terra
}
state = centopeia_state.subterranea;

// --- TIMERS E GATILHOS ---
action_timer = 0;
aviso_emergir = false;
alvo_x = x;
alvo_y = y;

piscar = 0;          // Flash de dano
queimando_timer = 0; // Suporte para queimadura da lança
image_yscale = 0.6; // Reduz a altura física da Centopeia para o Rato conseguir pular por cima!