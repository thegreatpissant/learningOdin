package tanks

import "base:runtime"
import "core:fmt"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

AppInit :: proc "c" (
	appState: ^rawptr,
	argc: i32,
	argv: [^]cstring,
) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initialize SDL")
	if !sdl.Init({.VIDEO, .AUDIO}) {
		fmt.printfln("Failed to initialize SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize SDL - DONE")

	fmt.printfln("Initialize SDL_TTF")
	if !sdl_ttf.Init() {
		fmt.printfln("Failed to initialize SDL_TTF %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize SDL_TTF - DONE")

	fmt.printfln("Initialize App")
	app := new(sup.App)
	appState^ = app
	app.title = "tanks"
	app.width = 1280
	app.height = 720
	app.scale = 30
	app.player.transform.rotation = 0
	app.mainScene = new(sup.Scene)
	app.mainScene.appEvent = MainSceneEvent
	app.mainScene.appIterate = MainSceneIterate
	app.mainScene.width = 2000
	app.mainScene.height = 750
	borderWidth: f32 = 10
	app.mainScene.borderRect = sup.GameRect {
		1 + borderWidth,
		0 + borderWidth,
		app.mainScene.width - 2 * borderWidth,
		app.mainScene.height - 2 * borderWidth,
	}
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + 40,
			app.mainScene.borderRect.y + 40,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + app.mainScene.borderRect.w - 80,
			app.mainScene.borderRect.y + app.mainScene.borderRect.h - 80,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + 120,
			app.mainScene.borderRect.y + 40,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + app.mainScene.borderRect.w - 80,
			app.mainScene.borderRect.y + app.mainScene.borderRect.h - 80,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + 400,
			app.mainScene.borderRect.y + 40,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + app.mainScene.borderRect.w - 80,
			app.mainScene.borderRect.y + app.mainScene.borderRect.h - 80,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + 1200,
			app.mainScene.borderRect.y + 40,
			20,
			20,
		},
	)
	append(
		&app.mainScene.markers,
		sup.GameRect {
			app.mainScene.borderRect.x + app.mainScene.borderRect.w - 80,
			app.mainScene.borderRect.y + app.mainScene.borderRect.h - 80,
			20,
			20,
		},
	)
	app.scene = app.mainScene

	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	sup.SetTargetFPS(&app.fps, 60)
	app.fps.frameStartTicks = sdl.GetTicksNS()
	fmt.printfln("Initialize App - DONE")

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(
		app.title,
		app.width,
		app.height,
		{},
		&app.window,
		&app.renderer,
	) {
		fmt.printfln("Failed to create window and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	sdl.SetRenderLogicalPresentation(
		app.renderer,
		app.width,
		app.height,
		sdl.RendererLogicalPresentation.STRETCH,
	)
	fmt.printfln("Initialize Window - DONE")

	fmt.printfln("Init Textures")
	app.tankBodyTexture = sup.CreateTankTexture(app.renderer, app.scale)
	app.tankTurretTexture = sup.CreateTurretTexture(app.renderer, app.scale)
	fmt.printfln("Init Textures - DONE")

	fmt.printfln("Init Player")
	app.player.character = sup.Character.PLAYER
	app.player.transform.position.x = f32(app.width / 2)
	app.player.transform.position.y = f32(app.height / 2)
	app.player.transform.rotation = 0
	app.player.direction += {sup.Direction.NONE}
	app.player.texture.texture = app.tankBodyTexture
	app.player.texture.offset.x = f32(app.tankBodyTexture.w) * 0.5
	app.player.texture.offset.y = f32(app.tankBodyTexture.h) * 0.5
	app.player.transform.scale = {1, 1}
	app.player.rigidbody.acceleration = 100
	app.player.rigidbody.maxVelocity = 70
	app.player.rigidbody.maxAngularVelocity = 40
	app.player.rigidbody.angularAcceleration = 100
	app.player.rigidbody.angularDamping = 0.005

	turret := new(sup.Actor)
	turret.parent = &app.player
	turret.character = sup.Character.PLAYER
	turret.texture.texture = app.tankTurretTexture
	turret.transform.rotation = 0
	turret.transform.position.x = 0
	turret.transform.position.y = 0
	turret.texture.offset.x = 1 * app.scale
	turret.texture.offset.y = 1 * app.scale
	turret.transform.scale = {1, 1}
	turret.rigidbody.acceleration = 0
	turret.rigidbody.velocity = 0
	turret.rigidbody.maxVelocity = 40
	turret.rigidbody.maxAngularVelocity = 40
	turret.rigidbody.angularAcceleration = 100
	turret.rigidbody.angularDamping = 0.01
	turret.rigidbody.lockXAxis = true
	turret.rigidbody.lockYAxis = true
	turret.direction += {sup.Direction.NONE}
	append(&app.player.children, turret)

	fmt.printfln("Init Player - DONE")
	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	app := (^sup.App)(app)
	context = runtime.default_context()

	sup.StartFrame(&app.fps)

	// Render
	app.scene.appIterate(app)

	sdl.RenderPresent(app.renderer)
	sup.EndFrame(&app.fps)

	return sdl.AppResult.CONTINUE
}

AppEvent :: proc "c" (app: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	app := (^sup.App)(app)
	context = runtime.default_context()
	return app.scene.appEvent(app, event)
}

MainSceneIterate :: proc(app: ^sup.App) -> sdl.AppResult {
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	sup.UpdateActor(&app.player, deltaTime)
	sup.HandleActorCollisions(&app.player, &app.mainScene.borderRect)
	sup.UpdateCamera(app)
	sdl.SetRenderTarget(app.renderer, nil)
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sdl.SetRenderDrawColor(app.renderer, 0xff, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sup.RenderBorderRect(app.renderer, &app.camera, &app.mainScene.borderRect)
	for &rect in app.mainScene.markers {
		sup.RenderBorderRect(app.renderer, &app.camera, &rect)
	}
	sup.RenderTextureActor(app.renderer, &app.camera, &app.player)

	return sdl.AppResult.CONTINUE
}

MainSceneEvent :: proc(app: ^sup.App, event: ^sdl.Event) -> sdl.AppResult {
	#partial switch (event.type) {
	case sdl.EventType.QUIT:
		return sdl.AppResult.SUCCESS
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.Q:
			fallthrough
		case sdl.Scancode.ESCAPE:
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.F:
			sdl.SetWindowFullscreen(
				app.window,
				!(.FULLSCREEN in sdl.GetWindowFlags(app.window)),
			)
		}
	}
	sup.HandlePlayerEvent(event, app)
	return sdl.AppResult.CONTINUE
}

AppQuit :: proc "c" (app: rawptr, result: sdl.AppResult) {
	app := (^sup.App)(app)
	context = runtime.default_context()
	free(app)
	sdl_ttf.Quit()
	sdl.Quit()
}

main :: proc() {
	renderer := new(sdl.Renderer)
	renderer = nil
	argv: cstring = ""
	returnCode := sdl.EnterAppMainCallbacks(
		0,
		&argv,
		AppInit,
		AppIterate,
		AppEvent,
		AppQuit,
	)
	fmt.printfln("App returned : %v", returnCode)
}
