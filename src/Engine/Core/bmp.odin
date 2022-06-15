package engine

import "core:fmt"
import "core:os"
import "core:mem"

Bitmap_Header :: struct #packed {
file_type : u16,  // Type of the file
file_size : u32,  // Size of the file (in bytes)

reserved1 : u16,  // Reserved (0)
reserved2 : u16,  // Reserved (0)

data_offset : u32,  // Offset to the data (in bytes)
struct_size : u32,  // Struct size (in bytes )

width  : i32,   // Bitmap width  (in pixels)
height : i32,   // Bitmap height (in pixels)

planes    : u16,   // Color planes count (1)
bit_depth : u16,   // Bits per pixel

compression : u32,  // Compression type
image_size  : u32,  // Image size (in bytes)

x_pixels_per_meter : i32,   // X Bitmap_Pixels per meter
y_pixels_per_meter : i32,   // Y pixels per meter

colors_used      : u32,  // User color count
colors_important : u32,   // Important color count
}

Bitmap_Color :: struct #packed {
b, g, r: u8,
}

Bitmap_Pixel :: struct {
	using color: Bitmap_Color,
	a: u8,
}

Pixel :: struct #raw_union {
using pixel: Bitmap_Pixel,
value: u32,
}

BMP :: struct {
	data: [^]Pixel,
	width, height: int,
}

load_bmp :: proc(file_name: string) -> BMP {
	result: BMP;
	
	image, success := os.read_entire_file_from_filename(file_name);
	assert(success, "Failed to load image.");
	
	header := (^Bitmap_Header)(&image[0])^;
	
	result.data = cast([^]Pixel)&image[header.data_offset]; 
	result.width = cast(int)header.width;
	result.height = cast(int)header.height;
	
	return result;
}

V2 :: struct {
	x, y: int,
}

draw_bmp :: proc(bmp: ^BMP, pos: V2, buffer: ^Win32_Buffer) {
	Bitmap_Pixel :: [4]u8;
	
	pixel := mem.slice_ptr(cast(^Bitmap_Pixel)buffer.memory, 
						   buffer.width * buffer.height);
	bmp_p := mem.slice_ptr(cast(^Bitmap_Pixel)bmp.data, bmp.width * bmp.height);
	
	to: V2 = {
		max(pos.x, 0),
		max(pos.y, 0),
	}
	
	end: V2 = {
		min(pos.x + bmp.width, buffer.width),
		min(pos.y + bmp.height, buffer.height),
	}
	
	for y in to.y..<end.y { // same as for y := to.y; y < end.y; y+= 1
        for x in to.x..<end.x {
			
			pixel_index := y * buffer.width + x;
			bmp_index := ((bmp.height - 1 - y + pos.y) * bmp.width) + x - pos.x;
			
			color_blend := bmp_p[bmp_index].r | bmp_p[bmp_index].g | bmp_p[bmp_index].b | bmp_p[bmp_index].a;
			
			// Don't draw le unwanted pixelllls
			if color_blend < 128 {
				bmp_p[bmp_index].r = pixel[pixel_index].r;
				bmp_p[bmp_index].g = pixel[pixel_index].g;
				bmp_p[bmp_index].b = pixel[pixel_index].b;
				bmp_p[bmp_index].a = pixel[pixel_index].a;
			}
			
			pixel[pixel_index].r = bmp_p[bmp_index].r;
			pixel[pixel_index].g = bmp_p[bmp_index].g;
			pixel[pixel_index].b = bmp_p[bmp_index].b;
			pixel[pixel_index].a = bmp_p[bmp_index].a;
		}
	}
}

