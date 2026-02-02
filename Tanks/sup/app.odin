package sup

import fmt "core:fmt"
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

Transform :: struct {
	position:       sdl.FPoint,
	rotation:       f64,
	rotationOffset: sdl.FPoint,
	bodyOffset:     sdl.FPoint,
	width:          f32,
	height:         f32,
}

Rigidbody :: struct {
	mass: f32,
	vx:   f32,
	vy:   f32,
}

Actor :: struct {
	direction: Direction,
	transform: Transform,
	collider:  sdl.Rect,
	character: Character,
	texture:   ^sdl.Texture,
	rigidbody: Rigidbody,
	children:  [dynamic]^Actor,
	parent:    ^Actor,
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

GetPosition :: proc(actor: ^Actor) -> sdl.FPoint {
	if actor.parent == nil {
		return actor.transform.position
	}
	return actor.transform.position + GetPosition(actor.parent)
}

GetRotation :: proc(actor: ^Actor) -> f64 {
	if actor.parent == nil {
		return actor.transform.rotation
	}
	return actor.transform.rotation + GetRotation(actor.parent)
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

RenderTextureActor :: proc(
	renderer: ^sdl.Renderer,
	camera: ^sdl.FRect,
	actor: ^Actor,
) {
	position := GetPosition(actor)
	target := sdl.FRect {
		position.x - actor.transform.bodyOffset.x,
		position.y - actor.transform.bodyOffset.y,
		actor.transform.width,
		actor.transform.height,
	}

	//  object position - camera position
	target.x -= camera.x
	target.y -= camera.y
	sdl.RenderTextureRotated(
		renderer,
		actor.texture,
		nil,
		&target,
		GetRotation(actor),
		&actor.transform.rotationOffset,
		sdl.FlipMode.NONE,
	)

	for &child in actor.children {
		RenderTextureActor(renderer, camera, child)
	}
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
		actor.transform.rotation -= f64(Interval)
	}
	if actor.direction & Direction.RIGHT == Direction.RIGHT {
		actor.transform.rotation += f64(Interval)
	}
	actor.collider.w = i32(actor.transform.width)
	actor.collider.h = i32(actor.transform.height)
	actor.collider.x = i32(actor.transform.position.x)
	actor.collider.y = i32(actor.transform.position.y)
	for &child in actor.children {
		UpdateActor(child)
	}
}

HandleActorInGame :: proc(actor: ^Actor, collider: ^sdl.FRect) {
	if actor.transform.position.x < collider.x {
		actor.transform.position.x = collider.x
	}
	if actor.transform.position.x + actor.transform.height >
	   collider.x + collider.w {
		actor.transform.position.x =
			collider.x + collider.w - actor.transform.width
	}
	if actor.transform.position.y < collider.y {
		actor.transform.position.y = collider.y
	}
	if actor.transform.position.y + actor.transform.height >
	   collider.y + collider.h {
		actor.transform.position.y =
			collider.y + collider.h - actor.transform.height
	}
}

HandlePlayerEvent :: proc(event: ^sdl.Event, app: ^App) {
	keyStates := sdl.GetKeyboardState(nil)
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.A:
			app.player.direction |= Direction.LEFT
		case sdl.Scancode.D:
			app.player.direction |= Direction.RIGHT
		case sdl.Scancode.W:
			app.player.direction |= Direction.UP
		case sdl.Scancode.S:
			app.player.direction |= Direction.DOWN
		case sdl.Scancode.H:
			app.player.children[0].direction |= Direction.LEFT
		case sdl.Scancode.L:
			app.player.children[0].direction |= Direction.RIGHT
		}
	case sdl.EventType.KEY_UP:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.A:
			app.player.direction &~= Direction.LEFT
		case sdl.Scancode.D:
			app.player.direction &~= Direction.RIGHT
		case sdl.Scancode.W:
			app.player.direction &~= Direction.UP
		case sdl.Scancode.S:
			app.player.direction &~= Direction.DOWN
		case sdl.Scancode.H:
			app.player.children[0].direction &~= Direction.LEFT
		case sdl.Scancode.L:
			app.player.children[0].direction &~= Direction.RIGHT
		}}
}
