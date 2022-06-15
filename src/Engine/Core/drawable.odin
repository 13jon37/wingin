/*
   * This modules is merely for drawing primitive shapes in
* pixels.
 */

package engine

import "core:mem"

Rect :: struct {
	x, y, width, height: int,
}

draw_rect :: proc(rect: Rect, buffer: ^Win32_Buffer) {
	Bitmap_Pixel :: [4]u8;
	pixel := mem.slice_ptr(cast(^Bitmap_Pixel)buffer.memory, buffer.width * buffer.height);
	
	for y := rect.y; y < rect.y + rect.height; y += 1 {
        for x := rect.x; x < rect.x + rect.width; x += 1 {
			pixel_index := y * buffer.width + x;
            pixel[pixel_index].r = 255;
			pixel[pixel_index].g = 255;
			pixel[pixel_index].b = 200;
			pixel[pixel_index].a = 250;
		}
	}
}