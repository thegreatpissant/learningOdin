package sup

import sdl "vendor:sdl3"

App :: struct { 
	title : cstring,
	width : i32,
	height : i32,
	window: ^sdl.Window,
	renderer: ^sdl.Renderer,
	fps: FPS,
	scene: ^Scene,
	mainScene: ^Scene,
	introScene: ^Scene,
	player: Actor,
}

Actor :: struct { 
	position: sdl.FPoint,
	direction: Direction
}

Direction :: enum { 
	NONE = 0,
	UP = 1 << 0,
	DOWN = 1 << 1,
	LEFT = 1 << 2,
	RIGHT = 1 << 3
}

Scene :: struct { 
	appIterate : proc (app: ^App) -> sdl.AppResult,
	appEvent : proc (app: ^App, event: ^sdl.Event) -> sdl.AppResult,
}

