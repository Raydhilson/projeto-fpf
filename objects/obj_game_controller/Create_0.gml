// Congelamento de tempo (Hitstop)
hitstop_timer = 0;

// Tremor de câmera (Screen Shake)
shake_magnitude = 0;
shake_magnitude = 0;
shake_fade = 0.4; // Antes era 0.2. Com 0.5, o tremor dura apenas 2 ou 3 frames.

// --- SISTEMA DE PAUSA ---
is_paused = false;
pause_opcoes = ["CONTINUAR", "VOLTAR AO MENU INICIAL"];
pause_index = 0;