package main

import "core:fmt"
import wing "engine/core"
import "engine/thing"
import wmath "engine/math"
import mini "vendor:miniaudio"
import "core:strings"

// TODO(Jon):
// Engine: Audio, Camera
// Platform stuff: image loading using stb, device info
// FPS limiting

main :: proc() {
	window := wing.win32_create_window("Wingin");
	screen_width, screen_height := wing.win32_get_window_size(window.window);
	screen_buffer := wing.win32_create_buffer(screen_width, screen_height);
	
	// NOTE: if i call this as a proc from another file it crashes?? 
	engine: mini.engine;
	if mini.engine_init(nil, &engine) != mini.result.SUCCESS {
		fmt.println("Error init.");
		return;
	}
	defer mini.engine_uninit(&engine);
	
	sound: mini.sound;
	mini.sound_init_from_file(&engine,
							  strings.clone_to_cstring("Assets/Assets_Battle01.ogg"),
							  0,
							  nil,
							  nil,
							  &sound);
	
	mini.sound_set_volume(&sound, 0.010);
	mini.sound_set_looping(&sound, true);
	mini.sound_start(&sound);
	
	bmp  := wing.load_bmp("Assets/soldier.bmpx");
	bmp1 := wing.load_bmp("Assets/Sprite-0002.bmpx");
	bmp2 := wing.load_bmp("Assets/grass.bmpx");
	
	rect := wing.Rect {250, 50, 50, 50};
	v    := wing.V2 {250, 250};
	v1   := wing.V2 {500, 700};
	
	width, height := wing.get_monitor_size(window.window);
	fmt.println("Montior size:", width, "x", height);
	rate := wing.get_monitor_refresh_rate(window.device_context);
	fmt.println("Monitor refresh rate:", rate);
	
	thingy := thing.create_thing(wmath.V3f{5.0, 5.0, 0.0});
	
	fmt.println(thingy.position, thingy.uuid);
	
	for true {
		if wing.win32_app_should_close() do break;
		
		wing.win32_clear_screen(&screen_buffer);
		
		rect.x += 1;
		
		wing.draw_bmp(&bmp2, {500, 70}, &screen_buffer);
		wing.draw_bmp(&bmp1, v, &screen_buffer);
		wing.draw_bmp(&bmp, {500, 85}, &screen_buffer);
		
		wing.draw_rect(rect, &screen_buffer);
		wing.draw_rect({700, 100, 150, 150}, &screen_buffer);
		
		wing.win32_render_buffer(&screen_buffer, window.window, window.device_context);
	}
}
