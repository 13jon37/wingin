package engine

import "core:sys/win32"
import ostr "core:strings"

Win32_Window :: struct {
	window: win32.Hwnd,
	device_context: win32.Hdc,
}

wnd_proc :: proc "std" (hwnd: win32.Hwnd, 
						msg: u32,
						w_param: win32.Wparam, 
						l_param: win32.Lparam) -> win32.Lresult {
	result: win32.Lresult;
	
	switch msg
    {
        case win32.WM_CLOSE: {
            win32.destroy_window(hwnd);
        } 
        
        case win32.WM_DESTROY: {
            win32.post_quit_message(0);
        } 
        
        case: {
            result = win32.def_window_proc_a(hwnd, msg, w_param, l_param);
        } 
    }
	
	return result;
}

win32_create_window :: proc(window_name: string) -> Win32_Window {
	result: Win32_Window;
	
	window_instance := cast(win32.Hinstance)win32.get_module_handle_a(nil);
	
	assert(window_instance != nil, "Failed to get win32 instance.");
	
	wc: win32.Wnd_Class_A;
	
	wc.wnd_proc = wnd_proc;
	wc.class_name = "default_class";
	wc.instance = window_instance;
	wc.menu_name = nil;
	
	assert(win32.register_class_a(&wc) != 0, "Failed to register win32 window class.");
	
	result.window = win32.create_window_ex_a(0, 
											 wc.class_name,
											 ostr.clone_to_cstring(window_name),
											 win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE,
											 win32.CW_USEDEFAULT,
											 win32.CW_USEDEFAULT,
											 cast(i32)1280,
											 cast(i32)720,
											 nil, 
											 nil,
											 wc.instance, 
											 nil);
	
	assert(result.window != nil, "Failed to create win32 window.");
	
	result.device_context = win32.get_dc(result.window);
	win32.show_window(result.window, win32.SW_SHOW);
	win32.update_window(result.window);
	
	return result;
}

win32_app_should_close :: proc() -> bool {
	result: bool;
	
	msg: win32.Msg;
	
	for win32.peek_message_a(&msg, nil, 0, 0, win32.PM_REMOVE) { 
		win32.dispatch_message_a(&msg);
		win32.translate_message(&msg);
		
		if msg.message == win32.WM_QUIT {
			result = true;
			break;
		}
	}
	
	return result;
}

win32_get_window_size :: proc(window: win32.Hwnd) -> (int, int) {
	rect: win32.Rect;
	win32.get_client_rect(window, &rect);
	
	width := cast(int)(rect.right - rect.left);
	height := cast(int)(rect.bottom - rect.top);
	
	return width, height;
}

