package engine

import win32 "core:sys/win32"
import "core:c/libc"

Win32_Buffer :: struct {
	self: ^Win32_Buffer,
	bitmap_info: win32.Bitmap_Info, // Bitmap stuff for drawing buffer
	memory: rawptr,                 // The buffer screen memory
	width, height: int,             // Current screen size (ignores top bar)
}

win32_create_buffer :: proc(width: int, height: int) -> Win32_Buffer {
	result: Win32_Buffer;
	
	result.bitmap_info.size = size_of(win32.Bitmap_Info_Header);
	result.bitmap_info.width = cast(i32)width;
	result.bitmap_info.height = cast(i32)-height;
	result.bitmap_info.planes = 1;
	result.bitmap_info.bit_count = 32;
	result.bitmap_info.compression = win32.BI_RGB;
	
	result.width = width;
	result.height = height;
	
	buffer_size := width * height * size_of(i32);
	
	if result.memory != nil {
		win32.virtual_free(result.memory, 0, win32.MEM_RELEASE);
	}
	
	result.memory = win32.virtual_alloc(nil, 
										cast(uint)buffer_size, 
										win32.MEM_COMMIT | win32.MEM_RESERVE, win32.PAGE_READWRITE);
	
	result.self = &result;
	
	return result;
}

win32_resize_buffer :: proc(buffer: ^Win32_Buffer, width: int, height: int)
{
	if buffer.memory != nil {
		win32.virtual_free(buffer.memory, 0, win32.MEM_RELEASE);
	}
	
	buffer.bitmap_info.width = cast(i32)width;
	buffer.bitmap_info.height = cast(i32)-height;
	
	buffer_size := width * height * size_of(i32);
	
	buffer.memory =  win32.virtual_alloc(nil, 
										 cast(uint)buffer_size, 
										 win32.MEM_COMMIT | win32.MEM_RESERVE, win32.PAGE_READWRITE);
}

win32_clear_screen :: proc(buffer: ^Win32_Buffer) {
	size := buffer.width * buffer.height * size_of(i32);
	libc.memset(buffer.memory, 0xA5, cast(uint)size);
}

win32_render_buffer :: proc(buffer: ^Win32_Buffer, 
							window: win32.Hwnd,
							device_context: win32.Hdc) {
	
	new_width, new_height := win32_get_window_size(window);
	
	if buffer.width != new_width || buffer.height != new_height {
		win32_resize_buffer(buffer, new_width, new_height);
		
		// Set new sizes
		buffer.width = new_width;
		buffer.height = new_height;
	}
	
	win32.stretch_dibits(device_context, 
						 0, 0, 
						 cast(i32)buffer.width, 
						 cast(i32)buffer.height, 
						 0, 0, 
						 cast(i32)buffer.width, 
						 cast(i32)buffer.height,
						 buffer.memory,
						 &buffer.bitmap_info,
						 win32.DIB_RGB_COLORS,
						 win32.SRCCOPY);
}