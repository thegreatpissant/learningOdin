package ex10

import log "core:log"
import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Text :: struct {
    text: string,
    ptsize: f32,
    color: sdl.Color,
    texture : Texture,
    position: sdl.FRect,
}

TextureFromText :: proc(app: ^App, text: string, color: sdl.Color, texture: ^^Texture) -> bool {
	if texture^ == nil {
		texture^ = new(Texture)
	}
	renderer := app.window.renderer
	DestroyTexture(texture^)

	ctext := strings.clone_to_cstring(text)
	defer delete(ctext)

	textSurface: ^sdl.Surface = sdl_ttf.RenderText_Blended(app.font, ctext, 0, color)
	if textSurface == nil {
		sdl.Log("Unable to render text surface! sdl_ttf Error: %s\n", sdl.GetError())
		return false
	}
	texture^.width = textSurface.w
	texture^.height = textSurface.h

	texture^.texture = sdl.CreateTextureFromSurface(renderer, textSurface)
	sdl.DestroySurface(textSurface)

	if texture^.texture == nil {
		sdl.Log("Failed to create texture from rendered text! sdl error: %s\n", sdl.GetError())
		return false
	}

	return true
}

StringTexture :: proc(app: ^App, text: string) -> ^Texture {
	texture := new(Texture)
	if !TextureFromText(app, text, sdl.Color{0xff, 0x00, 0x00, 0xff}, &texture) {
		log.info("Failed to create text \"foo\" texture")
		return nil
	} else {
		return texture
	}
}

CreateFont :: proc(fontPath: string, ptsize: f32) -> ^sdl_ttf.Font {
	cpath := strings.clone_to_cstring(fontPath)
	defer delete(cpath)
	font := sdl_ttf.OpenFont(cpath, ptsize)
	if font == nil {
		sdl.Log("Failed to create sdl font %s", sdl.GetError())
		return nil
	}
	return font
}

