package ex13

import "core:mem"
import "base:runtime"
import "core:fmt"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"
import sup "sup"

track: mem.Tracking_Allocator

AppInit :: proc "c" (appState: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initialize SDL")
	if !sdl.Init({ .VIDEO }) { 
		fmt.printfln("Failed to initialize SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize SDL - Done")

	fmt.printfln("Initialize SDL_TTF")
	if !sdl_ttf.Init() { 
		fmt.printfln("Failed to initialize SDL_TTF %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize SDL_TTF - Done")

	fmt.printfln("Initialize App")
	app := new (sup.App)
	appState^ = app
	app.title = "ex13"
	app.width = 640
	app.height = 480
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	fmt.printfln("Initialize App - Done")

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, { }, &app.window, &app.renderer) { 
		fmt.printfln("Failed to create window and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize Window - Done")
	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	app := (^sup.App)(app)
	context = runtime.default_context()
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sdl.RenderPresent(app.renderer)
	return sdl.AppResult.CONTINUE
}

AppEvent :: proc "c" (app: rawptr, event:^sdl.Event) -> sdl.AppResult {
	app := (^sup.App)(app)
	context = runtime.default_context()
	#partial switch(event.type) { 
	case sdl.EventType.QUIT:
		return sdl.AppResult.SUCCESS
	case sdl.EventType.KEY_DOWN:
		#partial switch(event.key.scancode) { 
		case sdl.Scancode.Q:
			return sdl.AppResult.SUCCESS
		}
	}
	return sdl.AppResult.CONTINUE
}

AppQuit :: proc "c" (app: rawptr, result: sdl.AppResult) {
	app := (^sup.App)(app)
	context = runtime.default_context()
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
	argv :cstring= ""
	returnCode := sdl.EnterAppMainCallbacks(0, &argv, AppInit, AppIterate, AppEvent, AppQuit)
	fmt.printfln("App returned : %v", returnCode)
	for _, leak in track.allocation_map { 
		fmt.println("%v leaked %m", leak.location, leak.size)
	}
}
