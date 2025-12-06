package scaffolding

import strings "core:strings"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Text :: struct {
	text:     string,
	color:    sdl.Color,
	texture:  ^Texture,
	position: sdl.FRect,
	font:     ^sdl_ttf.Font,
}

UpdateText :: proc(app: ^App, textBox: ^Text) -> bool {
	if textBox.texture == nil {
		textBox.texture = new(Texture)
	}
	renderer := app.window.renderer
	DestroyTexture(textBox.texture)

	ctext := strings.clone_to_cstring(textBox.text)
	defer delete(ctext)

	textSurface: ^sdl.Surface = sdl_ttf.RenderText_Blended(app.font, ctext, 0, textBox.color)
	if textSurface == nil {
		sdl.Log("Unable to render text surface! sdl_ttf Error: %s\n", sdl.GetError())
		return false
	}
	textBox.texture.width = textSurface.w
	textBox.texture.height = textSurface.h

	textBox.texture.texture = sdl.CreateTextureFromSurface(renderer, textSurface)
	sdl.DestroySurface(textSurface)

	if textBox.texture.texture == nil {
		sdl.Log("Failed to create texture from rendered text! sdl error: %s\n", sdl.GetError())
		return false
	}

	return true
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

RenderText :: proc(app: ^App, text: ^Text) {
	RenderTexture(
		text.texture,
        sdl.FRect { 0, 0, f32(text.texture.width), f32(text.texture.height)},
		sdl.FRect {
			f32((app.width / 2) - text.texture.width / 2),
			f32((app.height / 2) - text.texture.height / 2),
			f32(text.texture.width),
			f32(text.texture.height),
		},
		app,
		0,
		sdl.FPoint{f32(text.texture.width / 2), f32(text.texture.height / 2)},
	)
}

