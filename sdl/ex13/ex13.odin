package ex13

import "base:runtime"
import "core:fmt"
import "core:math/rand"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

AppInit :: proc "c" (appState: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initialize SDL")
	if !sdl.Init({.VIDEO}) {
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
	app.title = "ex13"
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
	app.ball.xDir = 1
	app.ball.yDir = 1
	app.ball.xVel = rand.float32() * 500
	app.ball.yVel = rand.float32() * 750
	fmt.printfln("Initialize App - DONE")

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, {}, &app.window, &app.renderer) {
		fmt.printfln("Failed to create window and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize Window - DONE")

	fmt.printfln("Loading Textures")
	if !sup.LoadTexture(app, "./assets/02-textures-and-extension-libraries/dot.png", &app.ball.texture) {
		fmt.printfln("Failed to load texture")
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Loading Textures - DONE")

	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	// ^^INPUT
	app := (^sup.App)(app)
	context = runtime.default_context()
	sup.StartFrame(&app.fps)
	// Update objects
	buf: [256]u8
	app.text.text = fmt.bprintf(buf[:], "%v fps", app.fps.fps)


	delta := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
//	fmt.printfln("app.fps.delta: %v, Delta time : %f", app.fps.delta, delta)
	app.ball.pos.x += app.ball.xVel * app.ball.xDir * delta
	app.ball.pos.y += app.ball.yVel * app.ball.yDir * delta
	if i32(app.ball.pos.x) + app.ball.texture.width > app.width {
		app.ball.xDir = -1
		app.ball.pos.x = f32(app.width - app.ball.texture.width)
	}
	if i32(app.ball.pos.x) <= 0 {
		app.ball.xDir = 1
		app.ball.pos.x = 0
	}
	if i32(app.ball.pos.y) + app.ball.texture.height > app.height {
		app.ball.yDir = -1
		app.ball.pos.y = f32(app.height - app.ball.texture.height)
	}
	if i32(app.ball.pos.y) <= 0 {
		app.ball.yDir = 1
		app.ball.pos.y = 0
	}
//	fmt.printfln("Ball position %v ", app.ball.pos)


	// Render
	sdl.SetRenderDrawColor(app.renderer, 0xff, 0xff, 0xff, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.UpdateText(app.renderer, app.text)
	sup.RenderText(app, app.text, &app.text.position)
	sup.RenderTexture(
		app.ball.texture,
		sdl.FRect{0, 0, f32(app.ball.texture.width), f32(app.ball.texture.height)},
		sdl.FRect{app.ball.pos.x, app.ball.pos.y, f32(app.ball.texture.width), f32(app.ball.texture.height)},
		app,
		0,
		sdl.FPoint{0, 0},
	)
	sdl.RenderPresent(app.renderer)
	sup.EndFrame(&app.fps)
	return sdl.AppResult.CONTINUE
}

AppEvent :: proc "c" (app: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	app := (^sup.App)(app)
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
			app.ball.yVel += 10
		case sdl.Scancode.DOWN:
			app.ball.yVel -= 10
		case sdl.Scancode.LEFT:
			app.ball.xVel -= 10
		case sdl.Scancode.RIGHT:
			app.ball.xVel += 10
		}
		if app.ball.yVel < 0 {
			app.ball.yVel = 0
		}
		if app.ball.xVel < 0 {
			app.ball.xVel = 0
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

