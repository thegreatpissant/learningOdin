package ex16

import "base:runtime"
import "core:fmt"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

collider1 := sup.BoxCollider{ }
collider2 := sup.BoxCollider{ }

AppInit :: proc "c" (appState: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initialize SDL")
	if !sdl.Init({.VIDEO , .AUDIO}) {
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
	app.title = "ex16"
	app.width = 640
	app.height = 480
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	app.font = sup.CreateFont("./assets/08-true-type-fonts/lazy.ttf", 22)
	app.text = new(sup.Text)
	app.text.color = sdl.Color{0xff, 0x00, 0x00, 0x00}
	app.text.font = app.font
	app.text.position = sdl.FPoint{0, 0}
	sup.SetTargetFPS(&app.fps, 60)
	app.fps.frameStartTicks = sdl.GetPerformanceCounter()
	fmt.printfln("Initialize App - DONE")

	fmt.printfln("Initialize Actors")
	collider1.rect.x = 0
	collider1.rect.y = 0
	collider1.rect.w = 50
	collider1.rect.h = 50
	collider2.rect.x = 100
	collider2.rect.y = 100
	collider2.rect.w = 50
	collider2.rect.h = 50
	fmt.printfln("Initialize Actors - DONE")

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, {}, &app.window, &app.renderer) {
		fmt.printfln("Failed to create window and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize Window - DONE")

	fmt.printfln("Loading Textures")
	fmt.printfln("Loading Textures - DONE")

	fmt.printfln("Initialize Audio")
	fmt.printfln("Initialize Audio - DONE")
	return sdl.AppResult.CONTINUE
}

/*
   AudioStreamBuffer
*/
AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	// --> INPUT
	// Init
	app := (^sup.App)(app)
	context = runtime.default_context()
	sup.StartFrame(&app.fps)
	// Update objects
	buf: [256]u8
	app.text.text = fmt.bprintf(buf[:], "%v fps", app.fps.fps)
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)

	// Audio

	// Render
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.UpdateText(app.renderer, app.text)
	sup.RenderText(app, app.text, &app.text.position)
	sdl.SetRenderDrawBlendMode(app.renderer, sdl.BLENDMODE_BLEND)
	if sup.Collides(&collider1, &collider2) { 
		sup.RenderBoxCollider(app, &collider1, sdl.Color{ 0xff, 0x00, 0x00, 0x44})
		sup.RenderBoxCollider(app, &collider2, sdl.Color{ 0x00, 0x00, 0xFF, 0x44})
	} else { 
		sup.RenderBoxCollider(app, &collider1, sdl.Color{ 0xff, 0x00, 0x00, 0x77 })
		sup.RenderBoxCollider(app, &collider2, sdl.Color{ 0x00, 0x00, 0xff, 0x77})
	}
	sdl.RenderPresent(app.renderer)
	sup.EndFrame(&app.fps)
	return sdl.AppResult.CONTINUE
}

AppEvent :: proc "c" (app: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	app := (^sup.App)(app)
	offset :: 10
	context = runtime.default_context()
	#partial switch (event.type) {
	case sdl.EventType.QUIT:
		return sdl.AppResult.SUCCESS
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.Q:
			fallthrough
		case sdl.Scancode.ESCAPE:
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.PAGEUP:
			sup.SetTargetFPS(&app.fps, app.fps.targetFPS + 10)
		case sdl.Scancode.UP:
			collider1.rect.y -= offset
		case sdl.Scancode.DOWN:
			collider1.rect.y += offset
		case sdl.Scancode.LEFT:
			collider1.rect.x -= offset
		case sdl.Scancode.RIGHT:
			collider1.rect.x += offset
		case sdl.Scancode.W:
			collider2.rect.y -= offset
		case sdl.Scancode.S:
			collider2.rect.y += offset
		case sdl.Scancode.A:
			collider2.rect.x -= offset
		case sdl.Scancode.D:
			collider2.rect.x += offset
		}
	}
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
	returnCode := sdl.EnterAppMainCallbacks(0, &argv, AppInit, AppIterate, AppEvent, AppQuit)
	fmt.printfln("App returned : %v", returnCode)
}

