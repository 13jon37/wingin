package engine

/* 
    * Device information using winapi.
 */

foreign import wingdi "system:gdi32.lib"
import "core:sys/win32"

// Had to import this function just for the monitor refresh rate
VREFRESH :: 116; // Index number for second paramter
@(default_calling_convention = "std")
foreign wingdi {
	@(link_name="GetDeviceCaps")
		get_device_caps :: proc(hdc: win32.Hdc,
								index: int) -> int ---;
}

get_monitor_size :: proc(window: win32.Hwnd) -> (int, int) {
	main_monitor := win32.monitor_from_window(window, win32.MONITOR_DEFAULTTONEAREST);
	
	monitor_info: win32.Monitor_Info;
	
	monitor_info.size = size_of(win32.Monitor_Info);
	
	win32.get_monitor_info_a(main_monitor, &monitor_info);
	
	using monitor_info;
	width := cast(int)(monitor.right - monitor.left);
	height := cast(int)(monitor.bottom - monitor.top);
	
	return width, height;
}

get_monitor_refresh_rate :: proc(device_context: win32.Hdc) -> int {
	return get_device_caps(device_context, VREFRESH);
}