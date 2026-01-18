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
	player: Actor,
	camera: sdl.FRect,
}

Actor :: struct { 
	position: sdl.FPoint,
	direction: Direction,
	collider: sdl.Rect,
	character: Character,
	width: f32,
	height: f32
}

Direction :: enum { 
	NONE = 0,
	UP = 1 << 0,
	DOWN = 1 << 1,
	LEFT = 1 << 2,
	RIGHT = 1 << 3
}

Character :: enum { 
	NONE = 0,
	PLAYER = 1,
	NPC = 2,
}

DOOR :: struct { 
	position: sdl.FPoint,
	destination: ^DOOR,
	collider: sdl.Rect,
	scene: ^Scene,
	width: f32,
	height: f32,
	color: sdl.Color
}

Scene :: struct { 
	borderRect: sdl.FRect,
	markers: [dynamic]sdl.FRect,
	width: f32,
	height: f32,
	appIterate : proc (app: ^App) -> sdl.AppResult,
	appEvent : proc (app: ^App, event: ^sdl.Event) -> sdl.AppResult,
}

RenderBorderRect :: proc(renderer:^sdl.Renderer, camera: ^sdl.FRect, border:^sdl.FRect) { 
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect{border.x, border.y, border.w, border.h}
	//  object position - camera position
	fRect.x -= camera.x
	fRect.y -= camera.y
	sdl.RenderRect(renderer, &fRect)
}

RenderPlayer :: proc(renderer:^sdl.Renderer, camera: ^sdl.FRect, player:^Actor) { 
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect{player.position.x, player.position.y, 
		player.width, player.height}
	//  object position - camera position
	fRect.x -= camera.x
	fRect.y -= camera.y
	sdl.RenderRect(renderer, &fRect)
}

UpdateCamera :: proc(app: ^App) {
	//  Camera follows the player position
	app.camera.x = app.player.position.x - .5 * f32(app.width)
	app.camera.y = app.player.position.y - .5 * f32(app.height)
	app.camera.w = f32(app.width)
	app.camera.h = f32(app.height)
	if app.camera.x < 0 { 
		app.camera.x = 0
	}
	if app.camera.x + app.camera.w > app.scene.width { 
		app.camera.x = app.scene.width - app.camera.w
	}
	if app.camera.y < 0 { 
		app.camera.y = 0
	}
	if app.camera.y + app.camera.h > app.scene.height { 
		app.camera.y = app.scene.height - app.camera.h
	}
}
UpdateActor :: proc(actor: ^Actor) {
	Interval: f32 = 10
	if actor.direction & Direction.UP == Direction.UP {
		actor.position.y -= Interval
	}
	if actor.direction & Direction.DOWN == Direction.DOWN {
		actor.position.y += Interval
	}
	if actor.direction & Direction.LEFT == Direction.LEFT {
		actor.position.x -= Interval
	}
	if actor.direction & Direction.RIGHT == Direction.RIGHT {
		actor.position.x += Interval
	}
	actor.collider.w = i32(actor.width)
	actor.collider.h = i32(actor.height)
	actor.collider.x = i32(actor.position.x)
	actor.collider.y = i32(actor.position.y)
}

HandleActorInGame :: proc(actor:^Actor, collider:^sdl.FRect){ 
	if actor.position.x < collider.x { 
		actor.position.x = collider.x
	}
	if actor.position.x + actor.height > collider.x + collider.w { 
		actor.position.x = collider.x + collider.w - actor.width
	}
	if actor.position.y < collider.y { 
		actor.position.y = collider.y
	}
	if actor.position.y + actor.height > collider.y + collider.h { 
		actor.position.y = collider.y + collider.h - actor.height
	}
}

HandlePlayerEvent :: proc(event: ^sdl.Event, app: ^App) {
	keyStates := sdl.GetKeyboardState(nil)
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.LEFT:
			app.player.direction |= Direction.LEFT
		case sdl.Scancode.RIGHT:
			app.player.direction |= Direction.RIGHT
		case sdl.Scancode.UP:
			app.player.direction |= Direction.UP
		case sdl.Scancode.DOWN:
			app.player.direction |= Direction.DOWN
		}
	case sdl.EventType.KEY_UP:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.LEFT:
			app.player.direction &~= Direction.LEFT
		case sdl.Scancode.RIGHT:
			app.player.direction &~= Direction.RIGHT
		case sdl.Scancode.UP:
			app.player.direction &~= Direction.UP
		case sdl.Scancode.DOWN:
			app.player.direction &~= Direction.DOWN
		}
	}
}

