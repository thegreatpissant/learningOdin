package sup

import fmt "core:fmt"
import math "core:math"
import sdl "vendor:sdl3"

Vec2 :: distinct [2]f32
#assert(size_of(Vec2) == size_of(sdl.FPoint))

GameRect :: struct {
	x, y: f32,
	w, h: f32,
}
#assert(size_of(GameRect) == size_of(sdl.FRect))

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
	camera:            GameRect,
	scale:             f32,
	tankBodyTexture:   ^sdl.Texture,
	tankTurretTexture: ^sdl.Texture,
}

Transform :: struct {
	position: Vec2,
	rotation: f32,
	scale:    Vec2,
	width:    f32,
	height:   f32,
}

Rigidbody :: struct {
	mass:                f32,
	vx:                  f32,
	vy:                  f32,
	maxVelocity:         f32,
	lockXAxis:           bool,
	lockYAxis:           bool,
	lockRotation:        bool,
	velocity:            f32,
	acceleration:        f32,
	maxAngularVelocity:  f32,
	angularVelocity:     f32,
	angularAcceleration: f32,
	angularDamping:      f32,
}

Actor :: struct {
	direction: Directions,
	transform: Transform,
	collider:  sdl.Rect,
	character: Character,
	texture:   Texture,
	rigidbody: Rigidbody,
	children:  [dynamic]^Actor,
	parent:    ^Actor,
}

Directions :: distinct bit_set[Direction]
Direction :: enum {
	NONE     = 0,
	UP       = 1 << 0,
	DOWN     = 1 << 1,
	LEFT     = 1 << 2,
	RIGHT    = 1 << 3,
	FORWARD  = 1 << 4,
	BACKWARD = 1 << 5,
}

Character :: enum {
	NONE   = 0,
	PLAYER = 1,
	NPC    = 2,
}

Texture :: struct {
	texture: ^sdl.Texture,
	offset:  Vec2,
}

DOOR :: struct {
	position:    sdl.FPoint,
	destination: ^DOOR,
	collider:    GameRect,
	scene:       ^Scene,
	width:       f32,
	height:      f32,
	color:       sdl.Color,
}

Scene :: struct {
	borderRect: GameRect,
	markers:    [dynamic]GameRect,
	width:      f32,
	height:     f32,
	appIterate: proc(app: ^App) -> sdl.AppResult,
	appEvent:   proc(app: ^App, event: ^sdl.Event) -> sdl.AppResult,
}

GetScale :: proc(actor: ^Actor) -> Vec2 {
	if actor.parent == nil {
		return actor.transform.scale
	}
	return actor.transform.scale * GetScale(actor.parent)
}

GetPosition :: proc(actor: ^Actor) -> Vec2 {
	if actor.parent == nil {
		return actor.transform.position
	}
	return actor.transform.position + GetPosition(actor.parent)
}

GetRotation :: proc(actor: ^Actor) -> f32 {
	if actor.parent == nil {
		return actor.transform.rotation
	}
	return actor.transform.rotation + GetRotation(actor.parent)
}

RenderBorderRect :: proc(
	renderer: ^sdl.Renderer,
	camera: ^GameRect,
	border: ^GameRect,
) {
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := GameRect{border.x, border.y, border.w, border.h}
	//  object position - camera position
	fRect.x -= camera.x
	fRect.y -= camera.y
	sdl.RenderRect(renderer, (^sdl.FRect)(&fRect))
}

RenderTextureActor :: proc(
	renderer: ^sdl.Renderer,
	camera: ^GameRect,
	actor: ^Actor,
) {
	position := GetPosition(actor)
	scale := GetScale(actor)
	target := GameRect {
		position.x - camera.x - (actor.texture.offset.x * scale.x),
		position.y - camera.y - (actor.texture.offset.y * scale.y),
		f32(actor.texture.texture.w) * scale.x,
		f32(actor.texture.texture.h) * scale.y,
	}

	//  object position - camera position
	//target.x -= camera.x
	//target.y -= camera.y
	sdl.RenderTextureRotated(
		renderer,
		actor.texture.texture,
		nil,
		(^sdl.FRect)(&target),
		f64(GetRotation(actor)),
		(^sdl.FPoint)(&actor.texture.offset),
		sdl.FlipMode.NONE,
	)

	for &child in actor.children {
		RenderTextureActor(renderer, camera, child)
	}
}

RenderActor :: proc(
	renderer: ^sdl.Renderer,
	camera: ^GameRect,
	actor: ^Actor,
) {
	sdl.SetRenderDrawColor(renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := GameRect {
		actor.transform.position.x,
		actor.transform.position.y,
		actor.transform.width,
		actor.transform.height,
	}
	//  object position - camera position
	fRect.x -= camera.x
	fRect.y -= camera.y
	sdl.RenderRect(renderer, (^sdl.FRect)(&fRect))
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

UpdateActor :: proc(actor: ^Actor, deltaTime: f32) {
	Interval := deltaTime
	if .FORWARD in actor.direction {
		actor.rigidbody.velocity += actor.rigidbody.acceleration * Interval
	} else if .BACKWARD in actor.direction {
		actor.rigidbody.velocity -= actor.rigidbody.acceleration * Interval
	} else {
		actor.rigidbody.velocity *= math.pow(0.1, Interval)
	}
	if .LEFT in actor.direction {
		actor.rigidbody.angularVelocity -=
			actor.rigidbody.angularAcceleration * Interval
	} else if .RIGHT in actor.direction {
		actor.rigidbody.angularVelocity +=
			actor.rigidbody.angularAcceleration * Interval
	} else {
		actor.rigidbody.angularVelocity *= math.pow(
			actor.rigidbody.angularDamping,
			Interval,
		)
	}
	actor.rigidbody.velocity = math.clamp(
		actor.rigidbody.velocity,
		-actor.rigidbody.maxVelocity,
		actor.rigidbody.maxVelocity,
	)
	actor.rigidbody.angularVelocity = math.clamp(
		actor.rigidbody.angularVelocity,
		-actor.rigidbody.maxAngularVelocity,
		actor.rigidbody.maxAngularVelocity,
	)

	rad := math.to_radians(actor.transform.rotation)
	direction := Vec2{math.cos(rad), math.sin(rad)}
	displacement := direction * actor.rigidbody.velocity * Interval
	if actor.rigidbody.lockXAxis {
		displacement.x = 0
	}
	if actor.rigidbody.lockYAxis {
		displacement.y = 0
	}
	actor.transform.position += displacement

	if !actor.rigidbody.lockRotation {
		actor.transform.rotation += actor.rigidbody.angularVelocity * Interval
	}

	scale := GetScale(actor)
	actor.collider.w = actor.texture.texture.w * i32(scale.x)
	actor.collider.h = actor.texture.texture.h * i32(scale.y)
	actor.collider.x = i32(
		actor.transform.position.x - actor.texture.offset.x * scale.x,
	)
	actor.collider.y = i32(
		actor.transform.position.y - actor.texture.offset.y * scale.y,
	)
	for &child in actor.children {
		UpdateActor(child, deltaTime)
	}
}

HandleActorCollisions :: proc(actor: ^Actor, collider: ^GameRect) {
	scale := GetScale(actor)
	if actor.transform.position.x < collider.x {
		actor.transform.position.x = collider.x
	}
	if actor.transform.position.x + f32(actor.texture.texture.w) * scale.x >
	   collider.x + collider.w {
		actor.transform.position.x =
			collider.x + collider.w - f32(actor.texture.texture.w) * scale.x
	}
	if actor.transform.position.y < collider.y {
		actor.transform.position.y = collider.y
	}
	if actor.transform.position.y + f32(actor.texture.texture.h) * scale.y >
	   collider.y + collider.h {
		actor.transform.position.y =
			collider.y + collider.h - f32(actor.texture.texture.h) * scale.y
	}
}

HandlePlayerEvent :: proc(event: ^sdl.Event, app: ^App) {
	keyStates := sdl.GetKeyboardState(nil)
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.A:
			app.player.direction += {Direction.LEFT}
		case sdl.Scancode.D:
			app.player.direction += {Direction.RIGHT}
		case sdl.Scancode.W:
			app.player.direction += {Direction.FORWARD}
		case sdl.Scancode.S:
			app.player.direction += {Direction.BACKWARD}
		case sdl.Scancode.H:
			app.player.children[0].direction += {Direction.LEFT}
		case sdl.Scancode.L:
			app.player.children[0].direction += {Direction.RIGHT}
		}
	case sdl.EventType.KEY_UP:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.A:
			app.player.direction -= {Direction.LEFT}
		case sdl.Scancode.D:
			app.player.direction -= {Direction.RIGHT}
		case sdl.Scancode.W:
			app.player.direction -= {Direction.FORWARD}
		case sdl.Scancode.S:
			app.player.direction -= {Direction.BACKWARD}
		case sdl.Scancode.H:
			app.player.children[0].direction -= {Direction.LEFT}
		case sdl.Scancode.L:
			app.player.children[0].direction -= {Direction.RIGHT}
		}}
}
