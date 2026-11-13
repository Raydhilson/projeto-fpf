// ==========================================
// 0. IDENTIFICAÇÃO DO JOGADOR (CO-OP LOCAL)
// ==========================================
if (!variable_instance_exists(id, "player_id")) {
    player_id = 0; // 0 = Player 1 | 1 = Player 2
}

// Cor base de cada jogador (Evita que o Step resete o P2 para branco)
base_blend = (player_id == 0) ? c_white : make_color_rgb(150, 220, 255);
image_blend = base_blend;

// ==========================================
// 0.5 SEGURANÇA DE CONTROLES (FALLBACK PADRONIZADO)
// ==========================================
if (!variable_global_exists("key_right"))     global.key_right     = ord("D");
if (!variable_global_exists("key_left"))      global.key_left      = ord("A");
if (!variable_global_exists("key_up"))        global.key_up        = ord("W");
if (!variable_global_exists("key_down"))      global.key_down      = ord("S");
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

carne_count    = 0;
glandula_count = 0;
ferrao_count   = 0;

global.ataque_base        = 10;
global.chance_critico     = 15;
global.multiplicador_crit = 2.0;

// ==========================================
// 2. SISTEMA DE CRAFTING E ABAS
// ==========================================
craft_timer = 0;
craft_time_max = 90; 
craft_cost = 5;      
craft_recipes = ["Curativo", "Molotov", "Faca de Arremesso"];
craft_cost_array = [3, 5, 8];
craft_selected_item = -1; 
menu_open = false;
menu_index = 0; 

aba_atual = 0;
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

queimando_player_timer = 0;

// ==========================================
// 4. SOBREVIVÊNCIA (HP, I-FRAMES E REVIVE CO-OP)
// ==========================================
hp_max = 100;
hp = hp_max;
is_invulnerable = false;
iframe_timer = 0;

revive_timer = 0;     // Progresso ao ser levantado pelo parceiro
revive_time_max = 90; // 1.5s segurando o botão de cura para reviver sem gastar item

// ==========================================
// 5. ESTAMINA E CANSAÇO
// ==========================================
stamina_max = 100;
stamina_current = stamina_max;
stamina_regen_rate = 0.8;      
stamina_delay_max = 45;        
stamina_delay_timer = 0;       

stamina_cost_attack = 10;      
stamina_cost_roll = 25;        

stamina_exhausted = false;
stamina_recovery_threshold = 25; 

// ==========================================
// 6. SISTEMA DE MAESTRIA E BUFFS (XP E COMBOS)
// ==========================================
arma_xp = 0;
arma_xp_max = 10;
arma_nivel = 1;
combo_count = 0;
ataque_buffer = false;
buff_fogo_timer = 0;

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
    menu,
    downed // NOVO: Nocauteado esperando resgate no Co-op!
}

state = player_state.idle;

// ==========================================
// 8. RESTAURA DADOS SE VEIO DO "CARREGAR JOGO" (Apenas P1)
// ==========================================
if (player_id == 0 && variable_global_exists("carregando_save") && global.carregando_save == true) {
    x              = global.load_x;
    y              = global.load_y;
    hp             = global.load_hp;
    curativo_count = global.load_curativos;
    molotov_count  = global.load_molotovs;
	faca_count = global.load_facas;
    arma_nivel     = global.load_arma_nivel;
    arma_xp        = global.load_arma_xp;
    
    carne_count    = global.load_carne;
    glandula_count = global.load_glandula;
    ferrao_count   = global.load_ferrao;
    
    global.carregando_save = false;
}