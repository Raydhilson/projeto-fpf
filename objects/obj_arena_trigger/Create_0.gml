// ==========================================
// CONFIGURAÇÃO DA ARENA DE LOCK-DOWN (WAVES)
// ==========================================
arena_state = 0; // 0 = Aguardando | 1 = Em Combate (Trancada) | 2 = Concluída
arena_half_w = 190; // Largura da metade da arena (Total = 380px, cabe na câmera 480x270!)
arena_height = 140; // Altura das grades de contenção

wave_atual = 0;
max_waves = 3;
wave_delay_timer = 0;
aviso_timer = 0;

// Guarda os IDs das paredes criadas para destruí-las no final
parede_esq = noone;
parede_dir = noone;

// Lista para rastrear apenas os inimigos nascidos nesta arena
inimigos_arena = [];