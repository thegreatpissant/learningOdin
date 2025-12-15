package sup

import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Position :: sdl.FPoint

Ball :: struct {
	texture: ^Texture,
	pos:     Position,
	xDir:    f32,
	yDir:    f32,
	xVel:    f32,
	yVel:    f32,
}
App :: struct {
	_context: runtime.Context,
	timer:    Timer,
	title:    cstring,
	window:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	width:    i32,
	height:   i32,
	font:     ^sdl_ttf.Font,
	text:     ^Text,
	fps:      FPS,
	ball:     Ball,
}

