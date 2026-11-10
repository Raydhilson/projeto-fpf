// ==========================================
// 0. SEGURANÇA DE CONTROLES (FALLBACK PADRONIZADO)
// ==========================================
if (!variable_global_exists("key_right"))     global.key_right     = vk_right;
if (!variable_global_exists("key_left"))      global.key_left      = vk_left;
if (!variable_global_exists("key_up"))        global.key_up        = vk_up;
if (!variable_global_exists("key_down"))      global.key_down      = vk_down;
if (!variable_global_exists("key_jump"))      global.key_jump      = vk_space;
if (!variable_global_exists("key_attack"))    global.key_attack    = ord("J");
if (!variable_global_exists("key_roll"))      global.key_roll      = ord("K");
if (!variable_global_exists("key_heal"))      global.key_heal      = ord("H");
if (!variable_global_exists("key_throw"))     global.key_throw     = ord("F");
if (!variable_global_exists("key_menu"))      global.key_menu      = ord("I");
if (!variable_global_exists("key_confirm"))   global.key_confirm   = vk_enter;
if (!variable_global_exists("key_tab_left"))  global.key_tab_left  = ord("Q");
if (!variable_global_exists("key_tab_right")) global.key_tab_right = ord("E");
if (!variable_global_exists("idioma"))        global.idioma        = "PT";

// ==========================================
// 1. ECONOMIA, CONSUMÍVEIS E MATERIAIS DE DROP
// ==========================================
if (!variable_global_exists("scrap")) global.scrap = 0;
curativo_count = 0; 
molotov_count  = 0;
faca_count     = 0;

// Materiais orgânicos que virão do Besouro e da Vespa (começam em 0)
carne_count    = 0; // Alimento (Besouro)
glandula_count = 0; // Glândula Química (Besouro)
ferrao_count   = 0; // Ferrão (Vespa)

// DEFININDO OS STATUS DE COMBATE
global.ataque_base        = 10;  // Dano normal da Lança de Prego
global.chance_critico     = 15;  // 15% de chance do golpe ser crítico
global.multiplicador_crit = 2.0; // Dano é multiplicado por 2 quando for crítico

// ==========================================
// 2. SISTEMA DE CRAFTING
// ==========================================
craft_timer = 0;
craft_time_max = 90; 
craft_cost = 5;      
craft_recipes = ["Curativo", "Molotov", "Faca de Arremesso"];
craft_cost_array = [3, 5, 8];
craft_selected_item = -1; 
menu_open = false;
menu_index = 0; 

// ==========================================
// 2.5 SISTEMA DE ABAS (HUB DO PERSONAGEM)
// ==========================================
aba_atual = 0; // 0 = Inventário, 1 = Crafting, 2 = Maestria
nome_abas = ["INVENTARIO", "CRAFTING", "MAESTRIA"];

// ==========================================
// 3. MOVIMENTO, FÍSICA E GAME FEEL
// ==========================================
hspd = 0;
vspd = 0;
walk_sp = 4;
grv = 0.4;
jump_spd = -9;
max_vspd = 10;       

accel = 0.22;        
fric = 0.15;         

coyote_time_max = 7; 
coyote_timer = 0;
jump_buffer_max = 7; 
jump_buffer_timer = 0;

wall_jump_vspd = -8; 
wall_jump_hspd = 6;  

scale_x = 1.0;       
scale_y = 1.0;

facing = 1;          
roll_sp = 7;         
action_timer = 0;   
slash_frame = 0;

// ==========================================
// 4. SOBREVIVÊNCIA (HP E I-FRAMES)
// ==========================================
hp_max = 100;
hp = hp_max;
is_invulnerable = false;
iframe_timer = 0;

// ==========================================
// 5. ESTAMINA E CANSAÇO
// ==========================================
stamina_max = 100;
stamina_current = stamina_max;
stamina_regen_rate = 0.8;      
stamina_delay_max = 45;        
stamina_delay_timer = 0;       

stamina_cost_attack = 20;      
stamina_cost_roll = 25;        

stamina_exhausted = false;
stamina_recovery_threshold = 25; 

// ==========================================
// 6. SISTEMA DE MAESTRIA E BUFFS (XP E COMBOS)
// ==========================================
arma_xp = 0;
arma_xp_max = 10;      // XP para Nível 2
arma_nivel = 1;        // Começa no Nível 1
combo_count = 0;       // Qual golpe estamos dando (1 ou 2)
ataque_buffer = false; // Guarda o clique do combo na memória
buff_fogo_timer = 0;   // Tempo ativo do Buff Instintivo do Besouro Bombardeiro

// ==========================================
// 7. MÁQUINA DE ESTADOS (FSM)
// ==========================================
enum player_state {
    idle,
    run,
    air,
    attack,
    roll,
    wall_slide,
    craft,
    menu
}

state = player_state.idle;

// ==========================================
// 8. RESTAURA DADOS SE VEIO DO "CARREGAR JOGO"
// ==========================================
if (variable_global_exists("carregando_save") && global.carregando_save == true) {
    x              = global.load_x;
    y              = global.load_y;
    hp             = global.load_hp;
    curativo_count = global.load_curativos;
    molotov_count  = global.load_molotovs;
    arma_nivel     = global.load_arma_nivel;
    arma_xp        = global.load_arma_xp;
    
    // Restaura os materiais orgânicos salvos na fogueira
    carne_count    = global.load_carne;
    glandula_count = global.load_glandula;
    ferrao_count   = global.load_ferrao;
    
    global.carregando_save = false; // Desliga a bandeira para não teleportar toda vez
}