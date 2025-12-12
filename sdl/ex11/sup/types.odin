package sup

import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

Position :: sdl.Point

App :: struct { 
	_context:runtime.Context,
	timer:Timer,
	title: cstring,
	window: ^sdl.Window,
	renderer: ^sdl.Renderer,
	width :i32,
	height :i32,
	font: ^sdl_ttf.Font,
	text: ^Text
}

