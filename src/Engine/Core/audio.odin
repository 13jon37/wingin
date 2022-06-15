package engine

import "core:sys/win32"
foreign import xaudio2 "core:xaudio2.lib"

@(default_calling_convention = "std")
foreign xaudio2 {
	@(link_name="XAudio2Create")
		xaudio2_create :: proc() -> win32.Hresult ---;
}

import "core:fmt"
import "core:strings"

init_sound_engine :: proc() {
	
}


