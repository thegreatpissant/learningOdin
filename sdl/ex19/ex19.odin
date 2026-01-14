package ex19

import "base:runtime"
import "core:fmt"
import "core:mem"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

track: mem.Tracking_Allocator
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
	app.title = "ex19"
	app.width = 640
	app.height = 480
	app.mainScene = new(sup.Scene)
	app.mainScene.appEvent = MainSceneEvent
	app.mainScene.appIterate = MainSceneIterate
	app.introScene = new(sup.Scene)
	app.introScene.appEvent = IntroSceneEvent
	app.introScene.appIterate = IntroSceneIterate
	app.scene = app.mainScene
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	app.player.position.x = 20
	app.player.position.y = 20
	app.player.direction = sup.Direction.NONE
	sup.SetTargetFPS(&app.fps, 60)
	app.fps.frameStartTicks = sdl.GetPerformanceCounter()
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
	fmt.printfln("Initialize Window - DONE")

	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	app := (^sup.App)(app)
	context = runtime.default_context()

	sup.StartFrame(&app.fps)

	// Render
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)

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

MoveActor :: proc(actor: ^sup.Actor) {
	Interval: f32 = 10
	if actor.direction & sup.Direction.UP == sup.Direction.UP {
		actor.position.y -= Interval
	}
	if actor.direction & sup.Direction.DOWN == sup.Direction.DOWN {
		actor.position.y += Interval
	}
	if actor.direction & sup.Direction.LEFT == sup.Direction.LEFT {
		actor.position.x -= Interval
	}
	if actor.direction & sup.Direction.RIGHT == sup.Direction.RIGHT {
		actor.position.x += Interval
	}
}

HandlePlayerEvent :: proc(event: ^sdl.Event, app: ^sup.App) {
	keyStates := sdl.GetKeyboardState(nil)
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.LEFT:
			app.player.direction |= sup.Direction.LEFT
		case sdl.Scancode.RIGHT:
			app.player.direction |= sup.Direction.RIGHT
		case sdl.Scancode.UP:
			app.player.direction |= sup.Direction.UP
		case sdl.Scancode.DOWN:
			app.player.direction |= sup.Direction.DOWN
		}
	case sdl.EventType.KEY_UP:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.LEFT:
			app.player.direction &~= sup.Direction.LEFT
		case sdl.Scancode.RIGHT:
			app.player.direction &~= sup.Direction.RIGHT
		case sdl.Scancode.UP:
			app.player.direction &~= sup.Direction.UP
		case sdl.Scancode.DOWN:
			app.player.direction &~= sup.Direction.DOWN
		}
	}
}

MainSceneIterate :: proc(app: ^sup.App) -> sdl.AppResult {
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	MoveActor(&app.player)
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0xff, 0x00, 0x00)
	fRect := sdl.FRect{app.player.position.x, app.player.position.y, 20, 20}
	sdl.RenderRect(app.renderer, &fRect)
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
		case sdl.Scancode.N:
			app.scene = app.introScene
		}
	}
	HandlePlayerEvent(event, app)
	return sdl.AppResult.CONTINUE
}

IntroSceneIterate :: proc(app: ^sup.App) -> sdl.AppResult {
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	MoveActor(&app.player)
	sdl.SetRenderDrawColor(app.renderer, 0xff, 0x00, 0x00, 0x00)
	fRect := sdl.FRect{app.player.position.x, app.player.position.y, 20, 20}
	sdl.RenderRect(app.renderer, &fRect)
	return sdl.AppResult.CONTINUE
}

IntroSceneEvent :: proc(app: ^sup.App, event: ^sdl.Event) -> sdl.AppResult {
	#partial switch (event.type) {
	case sdl.EventType.QUIT:
		return sdl.AppResult.SUCCESS
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.Q:
			fallthrough
		case sdl.Scancode.ESCAPE:
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.N:
			app.scene = app.mainScene
		}
	}
	HandlePlayerEvent(event, app)
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
	context = runtime.default_context()
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)
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
	for _, leak in track.allocation_map {
		fmt.println("%v leaked %m", leak.location, leak.size)
	}
}
