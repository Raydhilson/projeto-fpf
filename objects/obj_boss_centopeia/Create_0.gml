// --- ATRIBUTOS DO CHEFE ---
hp_max = 50;
hp = hp_max;
hspd = 0;
vspd = 0;
grv = 0.3;
facing = -1;

// --- ESTADOS DA CENTOPEIA ---
enum centopeia_state {
    subterranea,   // Escondida
    emergindo,     // Saindo do chão
    patrulha_luta, // Andando e escolhendo ataque
    investida,     // Bote rápido corpo a corpo
    cuspindo,      // NOVO: Ataque de projéteis de ácido
    cavando        // Voltando para a terra
}
state = centopeia_state.subterranea;

// --- TIMERS E GATILHOS ---
action_timer = 0;
aviso_emergir = false;
alvo_x = x;
alvo_y = y;

piscar = 0; // Para quando ela tomar dano do rato
queimando_timer = 0; // Suporte para queimadura da lança