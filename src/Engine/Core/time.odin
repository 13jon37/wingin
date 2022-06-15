package engine

import "core:sys/win32"

Win32_Time :: struct {
	target_herz: int, // Target refresh rate
	delta_time: f32,  // Time between frames
}

init_time :: proc(target_herz: int) -> Win32_Time {
	result: Win32_Time;
	
	result.target_herz = target_herz;
	result.delta_time = 0.0;
	
	return result;
}
