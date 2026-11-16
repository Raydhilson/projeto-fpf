// --- ATRIBUTOS DO CHEFE ---
hp_max = 50;
hp = hp_max;
hspd = 0;
vspd = 0;
grv = 0.3;

// --- DIREÇÃO E ALINHAMENTO DA SPRITE ---
facing = -1;     // 1 = Olhando para a Direita | -1 = Olhando para a Esquerda
sprite_dir = 1;  // CORRIGIDO PARA 1 (Alinha o olhar do Boss com o Rato!)
escala_boss = 1.0;

image_xscale = facing * sprite_dir * escala_boss;
image_yscale = escala_boss;

// --- ESTADOS DA CENTOPEIA ---
enum centopeia_state {
    subterranea,     // Escondida
    emergindo,       // Saindo do chão
    patrulha_luta,   // Andando e escolhendo ataque
    preparando_bote, // Aviso antes da investida ou execução da mordida
    investida,       // Bote rápido corpo a corpo
    recuperando,     // Janela de cansaço após ataques
    cuspindo,        // Ataque de projéteis de ácido
    cavando,         // Voltando para a terra
    mordida
}
state = centopeia_state.subterranea;

// --- TIMERS E GATILHOS ---
action_timer = 0;
aviso_emergir = false;
alvo_x = x;
alvo_y = y;

usando_mordida = false;
mordida_hitbox_ativa = false;
morrendo = false;

piscar = 0;          // Flash de dano
queimando_timer = 0; // Suporte para queimadura da lança