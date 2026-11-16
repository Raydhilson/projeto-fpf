// --- ATRIBUTOS BASE ---
hp = 3;
walk_spd = 1;       
chase_spd = 2.4;    
charge_spd = 5.2; // Velocidade da investida explosiva
hspd = 0;
vspd = 0;
grv = 0.3;

// --- ESCALA DE TAMANHO DO BESOURO (0.75 = 25% menor) ---
escala_base = 0.75;
image_xscale = escala_base;
image_yscale = escala_base;

// --- DIREÇÃO E ESTADOS ---
facing = 1;         
tipo_ataque_atual = 0; // 0 = Avanço (spr_enemy_attack) | 1 = Bombardeio (spr_enemy_attack_defense)

enum enemy_state {
    patrol,
    chase,
    chemical_prep, // Aviso visual: misturando reagentes químicos
    charge,        // Investida explosiva ou disparo químico
    cooldown       // Janela vulnerável pós-ataque
}
state = enemy_state.patrol;

// --- INTELIGÊNCIA ARTIFICIAL E TIMERS ---
vision_range = 160;        
lose_interest_range = 260; 
state_timer = 0;
attack_cooldown = 0;

// --- GAME FEEL, BUFF E EFEITOS DE COMBATE ---
piscar = 0;            // Controla o brilho branco e a imunidade rápida do knockback
eh_bombardeiro = true; // Se true, ao morrer concede o Buff de Fogo direto para a lança do Rato
queimando_timer = 0;   // Tempo que o inimigo fica pegando fogo (dano contínuo)