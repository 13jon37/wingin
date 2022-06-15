package main

import wing "engine/core"
import mini "vendor:miniaudio"
import "core:strings"
import "core:fmt"

Game_Application :: struct {
	window: wing.Win32_Window,
	screen_buffer: wing.Win32_Buffer,
	sound_engine: mini.engine,
	screen_width: int,
	screen_height: int,
}

init_game :: proc() -> Game_Application {
	result: Game_Application;
	
	result.window = wing.win32_create_window("Wingin");
	
	result.screen_width, result.screen_height = wing.win32_get_window_size(result.window.window);
	
	result.screen_buffer = wing.win32_create_buffer(result.screen_width, result.screen_height);
	
	return result;
}

run_game :: proc(game: ^Game_Application) {
	
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
	
	mini.sound_set_volume(&sound, 0.25);
	mini.sound_set_looping(&sound, true);
	mini.sound_start(&sound);
	
	for true {
		if wing.win32_app_should_close() do break;
		
		wing.win32_clear_screen(&game.screen_buffer);
		
		wing.win32_render_buffer(&game.screen_buffer, 
								 game.window.window, 
								 game.window.device_context);
	}
}