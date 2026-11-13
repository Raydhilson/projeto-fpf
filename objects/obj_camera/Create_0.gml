// --- CONFIGURAÇÃO DA CÂMERA ---
target = obj_player; // Quem a câmera deve seguir

// Resolução virtual da câmera (tamanho da janela que aparece na tela)
cam_width = 480;
cam_height = 270;

// Configura e ativa a View 0 do GameMaker
view_enabled = true;
view_visible[0] = true;

// Cria a câmera digital
camera = camera_create_view(0, 0, cam_width, cam_height);
view_set_camera(0, camera);

// --- CONFIGURAÇÃO DA CÂMERA ---
target = obj_player; // Quem a câmera deve seguir

// Resolução virtual da câmera (480x270 = escala exata 4x em 1080p)
cam_width = 480;
cam_height = 270;

view_enabled = true;
view_visible[0] = true;

// Cria a câmera digital e vincula à View 0
camera = camera_create_view(0, 0, cam_width, cam_height);
view_set_camera(0, camera);

// Garante que a surface nunca perca o tamanho nativo ao trocar de Room
surface_resize(application_surface, cam_width, cam_height);
gpu_set_tex_filter(false);