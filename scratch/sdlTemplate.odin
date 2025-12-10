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

	if !sdl.CreateWindowAndRenderer((^App)(appState).title,(^App)(appState).width, (^App)(appState).height, { }, &(^App)(appState).window, &(^App)(appState).renderer) { 
		fmt.printfln("Failed to CreateWindowAndRenderer SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	fmt.printfln("Initializing SDL - DONE")
	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (appState: rawptr) -> sdl.AppResult { 
    appState := (^App)(appState)
	context = appState._context
	sdl.RenderPresent(appState.renderer)
	return sdl.AppResult.SUCCESS
}
AppEvent :: proc "c" (appState: rawptr, event:^sdl.Event) -> sdl.AppResult { 
	context = (^App)(appState)._context
	return sdl.AppResult.SUCCESS
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
