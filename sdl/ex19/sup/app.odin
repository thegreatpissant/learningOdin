package sup

import sdl "vendor:sdl3"

App :: struct { 
	title : cstring,
	width : i32,
	height : i32,
	window: ^sdl.Window,
	renderer: ^sdl.Renderer,
	fps: FPS,
	mainScene: Scene,
}

Scene :: struct { 
	appIterate : proc (app: ^App) -> sdl.AppResult,
	appEvent : proc (app: ^App, event: ^sdl.Event) -> sdl.AppResult,
}

