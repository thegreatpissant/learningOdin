package ex11

import "core:fmt"
import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

App :: struct { 
	_context:runtime.Context,
	timer:Timer,
	title: cstring,
	window: ^sdl.Window,
	renderer: ^sdl.Renderer,
	width :i32,
	height :i32,
}

Timer :: struct { 
	startTicks : u64,
	pauseTicks : u64,
	started : bool,
	paused : bool
}

StartTimer :: proc(timer:^Timer){ 
	timer.started = true
	timer.paused = false
	timer.startTicks = sdl.GetTicksNS()
	timer.pauseTicks = 0
}
StopTimer :: proc(timer:^Timer) { 
	timer.started = false
	timer.paused = false
	timer.startTicks = 0
	timer.pauseTicks = 0
}

AppInit :: proc "c" (appState: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initializing SDL")
	app := new(App)
	app._context = context
	app.title = "Ex11"
	app.width = 200
	app.height = 200
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	appState^ = app

	if !sdl.Init({ .VIDEO }) { 
		fmt.printfln("Failed to Initialize SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, { }, &app.window, &app.renderer) { 
		fmt.printfln("Failed to CreateWindowAndRenderer SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	if !sdl.SetRenderVSync(app.renderer, 1){ 
		fmt.printfln("failed to set vsync")
	}

	fmt.printfln("Initializing SDL - DONE")
	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (appState: rawptr) -> sdl.AppResult { 
    appState := (^App)(appState)
	context = appState._context
	sdl.SetRenderDrawColor(appState.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(appState.renderer)
	sdl.SetRenderDrawColor(appState.renderer, 0xFF, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	//sdl.RenderLine(appState.renderer, 0, 0, f32(appState.width), f32(appState.height))
	sdl.RenderPresent(appState.renderer)
	return sdl.AppResult.CONTINUE
}

AppEvent :: proc "c" (appState: rawptr, event:^sdl.Event) -> sdl.AppResult { 
	appState := (^App)(appState)
	context = (^App)(appState)._context
	#partial switch (event.type) { 
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
AppQuit :: proc "c" (appState: rawptr, result: sdl.AppResult) { 
	appState := (^App)(appState)
	context = appState._context
	fmt.printfln("Closing %s with result %v", appState.title, result)
	sdl.Quit()
}
main :: proc() { 
	argv :cstring = ""
	sdl.EnterAppMainCallbacks(0, &argv, AppInit, AppIterate, AppEvent, AppQuit)
}
