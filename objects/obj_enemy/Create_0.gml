// --- ATRIBUTOS BASE ---
hp = 3;
hp_anterior = hp; // Usado para detectar quando tomou dano e acionar defesa!
walk_spd = 1;       
chase_spd = 2.4;    
charge_spd = 5.2; 
hspd = 0;
vspd = 0;
grv = 0.3;

// --- DIREÇÃO E ESTADOS ---
facing = 1;         

enum enemy_state {
    patrol,
    chase,
    chemical_prep,    // Aviso visual: misturando reagentes químicos para investida
    charge,           // Investida explosiva
    chemical_defense, // NOVO: Mecanismo de defesa que solta jato químico fervente!
    cooldown          // Janela vulnerável pós-ataque
}
state = enemy_state.patrol;

// --- INTELIGÊNCIA ARTIFICIAL E TIMERS ---
vision_range = 160;        
lose_interest_range = 260; 
state_timer = 0;
attack_cooldown = 0;
defense_cooldown = 0; // Tempo de recarga do spray químico defensivo

// --- GAME FEEL, BUFF E EFEITOS DE COMBATE ---
piscar = 0;            
eh_bombardeiro = true; 
queimando_timer = 0;