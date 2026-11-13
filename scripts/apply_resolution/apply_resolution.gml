function apply_resolution(){
	window_set_size(_res.w, _res.h);
window_center();

// Mantém a proporção correta do Viewport na tela
view_wport[0] = RESOLUTION_W;
view_hport[0] = RESOLUTION_H;

}