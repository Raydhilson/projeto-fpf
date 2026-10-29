// --- ATRIBUTOS BASE ---
hp = 3;
walk_spd = 1;       
chase_spd = 2.5;    
hspd = 0;
vspd = 0;
grv = 0.3;

// --- DIREÇÃO E ESTADOS ---
facing = 1;         

enum enemy_state {
    patrol,
    chase
}
state = enemy_state.patrol;

// --- INTELIGÊNCIA ARTIFICIAL ---
vision_range = 150;        
lose_interest_range = 250; 

// --- GAME FEEL E COMBATE ---
piscar = 0; // Controla o brilho branco e a imunidade rápida