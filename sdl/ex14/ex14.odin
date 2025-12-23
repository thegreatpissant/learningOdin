package ex14

import "base:runtime"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

track: mem.Tracking_Allocator

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
	app.title = "ex14"
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

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, {}, &app.window, &app.renderer) {
		fmt.printfln("Failed to create window and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize Window - DONE")

	fmt.printfln("Loading Textures")
	textureFrameCount :i32= 4
	if !sup.LoadTexture(app, "./assets/02-textures-and-extension-libraries/foo-sprites.png", &app.character.texture, textureFrameCount) {
		fmt.printfln("Failed to load texture")
		return sdl.AppResult.FAILURE
	}
	app.character.deltaTime = 0
	app.character.xDir = 1
	app.character.pos.y = f32(app.character.texture.height / 2)
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

	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	sup.UpdateCharacterAnimation(&app.character, app.fps.delta)

	if i32(app.character.pos.x) > app.width - app.character.texture.frameWidth { 
		app.character.xDir = -1
	} 
	if i32(app.character.pos.x) < 0 { 
		app.character.xDir = 1
	} 
	spriteDirection := app.character.xDir > 0 ? sdl.FlipMode.HORIZONTAL : sdl.FlipMode.NONE

	// move forward at the pace of the animation
	distancePerSecond := app.character.texture.width / app.character.texture.frames
	app.character.pos.x += f32(distancePerSecond) * app.character.xDir * f32(deltaTime)
	// Render
	sdl.SetRenderDrawColor(app.renderer, 0xff, 0xff, 0xff, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.UpdateText(app.renderer, app.text)
	sup.RenderText(app, app.text, &app.text.position)
	srcRect := sup.GetSrcRect(app.character.texture)
	sup.RenderTexture(
		app.character.texture,
		srcRect,
		sdl.FRect{app.character.pos.x, app.character.pos.y, f32(app.character.texture.frameWidth), f32(app.character.texture.height)},
		app,
		0,
		sdl.FPoint{0, 0},
		spriteDirection
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
	context = runtime.default_context()
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)
	renderer := new(sdl.Renderer)
	renderer = nil
	argv: cstring = ""
	returnCode := sdl.EnterAppMainCallbacks(0, &argv, AppInit, AppIterate, AppEvent, AppQuit)
	fmt.printfln("App returned : %v", returnCode)
	for _, leak in track.allocation_map {
		fmt.println("%v leaked %m", leak.location, leak.size)
	}
}

