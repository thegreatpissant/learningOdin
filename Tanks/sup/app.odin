package sup

import sdl "vendor:sdl3"

App :: struct {
	title:             cstring,
	width:             i32,
	height:            i32,
	window:            ^sdl.Window,
	renderer:          ^sdl.Renderer,
	fps:               FPS,
	scene:             ^Scene,
	mainScene:         ^Scene,
	player:            Actor,
	camera:            sdl.FRect,
	scale:             f32,
	tankBodyTexture:   ^sdl.Texture,
	tankTurretTexture: ^sdl.Texture,
}

Transform:: struct { 
	position:  sdl.FPoint,
	rotation:  f64,
	width:     f32,
	height:    f32,
}

Texture :: struct { 
	transform: Transform,
	texture: ^sdl.Texture
}

Actor :: struct {
	direction: Direction,
	transform: Transform,
	collider:  sdl.Rect,
	character: Character,
	texture:   Texture,
}

Direction :: enum {
	NONE  = 0,
	UP    = 1 << 0,
	DOWN  = 1 << 1,
	LEFT  = 1 << 2,
	RIGHT = 1 << 3,
}

Character :: enum {
	NONE   = 0,
	PLAYER = 1,
	NPC    = 2,
}

DOOR :: struct {
	position:    sdl.FPoint,
	destination: ^DOOR,
	collider:    sdl.Rect,
	scene:       ^Scene,
	width:       f32,
	height:      f32,
	color:       sdl.Color,
}

Scene :: struct {
	borderRect: sdl.FRect,
	markers:    [dynamic]sdl.FRect,
	width:      f32,
	height:     f32,
	appIterate: proc(app: ^App) -> sdl.AppResult,
	appEvent:   proc(app: ^App, event: ^sdl.Event) -> sdl.AppResult,
}

RenderBorderRect :: proc(
	renderer: ^sdl.Renderer,
	camera: ^sdl.FRect,
	border: ^sdl.FRect,
) {
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect{border.x, border.y, border.w, border.h}
	//  object position - camera position
	fRect.x -= camera.x
	fRect.y -= camera.y
	sdl.RenderRect(renderer, &fRect)
}

RenderActor :: proc(
	renderer: ^sdl.Renderer,
	camera: ^sdl.FRect,
	actor: ^Actor,
) {
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect {
		actor.transform.position.x,
		actor.transform.position.y,
		actor.transform.width,
		actor.transform.height,
	}
	//  object position - camera position
	fRect.x -= camera.x
	fRect.y -= camera.y
	sdl.RenderRect(renderer, &fRect)
}

UpdateCamera :: proc(app: ^App) {
	//  Camera follows the player position
	app.camera.x = app.player.transform.position.x - .5 * f32(app.width)
	app.camera.y = app.player.transform.position.y - .5 * f32(app.height)
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
		actor.transform.position.y -= Interval
	}
	if actor.direction & Direction.DOWN == Direction.DOWN {
		actor.transform.position.y += Interval
	}
	if actor.direction & Direction.LEFT == Direction.LEFT {
		//actor.position.x -= Interval
		actor.transform.rotation -= f64(Interval)
	}
	if actor.direction & Direction.RIGHT == Direction.RIGHT {
		//actor.position.x += Interval
		actor.transform.rotation += f64(Interval)
	}
	actor.collider.w = i32(actor.transform.width)
	actor.collider.h = i32(actor.transform.height)
	actor.collider.x = i32(actor.transform.position.x)
	actor.collider.y = i32(actor.transform.position.y)
}

HandleActorInGame :: proc(actor: ^Actor, collider: ^sdl.FRect) {
	if actor.transform.position.x < collider.x {
		actor.transform.position.x = collider.x
	}
	if actor.transform.position.x + actor.transform.height > collider.x + collider.w {
		actor.transform.position.x = collider.x + collider.w - actor.transform.width
	}
	if actor.transform.position.y < collider.y {
		actor.transform.position.y = collider.y
	}
	if actor.transform.position.y + actor.transform.height > collider.y + collider.h {
		actor.transform.position.y = collider.y + collider.h - actor.transform.height
	}
}

HandlePlayerEvent :: proc(event: ^sdl.Event, app: ^App) {
	keyStates := sdl.GetKeyboardState(nil)
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.H:
			fallthrough
		case sdl.Scancode.LEFT:
			app.player.direction |= Direction.LEFT
		case sdl.Scancode.L:
			fallthrough
		case sdl.Scancode.RIGHT:
			app.player.direction |= Direction.RIGHT
		case sdl.Scancode.K:
			fallthrough
		case sdl.Scancode.UP:
			app.player.direction |= Direction.UP
		case sdl.Scancode.J:
			fallthrough
		case sdl.Scancode.DOWN:
			app.player.direction |= Direction.DOWN
		}
	case sdl.EventType.KEY_UP:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.H:
			fallthrough
		case sdl.Scancode.LEFT:
			app.player.direction &~= Direction.LEFT
		case sdl.Scancode.L:
			fallthrough
		case sdl.Scancode.RIGHT:
			app.player.direction &~= Direction.RIGHT
		case sdl.Scancode.K:
			fallthrough
		case sdl.Scancode.UP:
			app.player.direction &~= Direction.UP
		case sdl.Scancode.J:
			fallthrough
		case sdl.Scancode.DOWN:
			app.player.direction &~= Direction.DOWN
		}
	}
}
