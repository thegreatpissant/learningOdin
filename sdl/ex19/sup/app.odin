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
	height: f32
}

Scene :: struct { 
	door: ^DOOR,
	appIterate : proc (app: ^App) -> sdl.AppResult,
	appEvent : proc (app: ^App, event: ^sdl.Event) -> sdl.AppResult,
}

RenderPlayer :: proc(renderer:^sdl.Renderer, player:^Actor) { 
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect{player.position.x, player.position.y, 
		player.width, player.height}
	sdl.RenderRect(renderer, &fRect)
}

DoorThePlayer :: proc (player: ^Actor, door: ^DOOR){ 
	if door.destination != nil { 
		player.position = door.destination.position
		player.position.x += door.destination.width + 5
		player.position.y += door.destination.height + 5 
	}
}

TeleportPlayer :: proc (player: ^Actor, destination: sdl.FPoint) { 
	player.position = destination
}

UpdateDoor :: proc(door:^DOOR){ 
	door.collider.h = i32(door.height)
	door.collider.w = i32(door.width)
	door.collider.x = i32(door.position.x)
	door.collider.y = i32(door.position.y)
}

RenderDoor :: proc(renderer:^sdl.Renderer,door:^DOOR) {
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect{door.position.x, door.position.y, 
		door.width, door.height}
	sdl.RenderFillRect(renderer, &fRect)
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

