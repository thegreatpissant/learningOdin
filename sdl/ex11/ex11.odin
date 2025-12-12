package ex11

import "core:fmt"
import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"
import sup "sup"

AppInit :: proc "c" (appState: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initializing SDL")
	if !sdl.Init({ .VIDEO }) { 
		fmt.printfln("Failed to Initialize SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	if !sdl_ttf.Init() { 
		fmt.printfln("Failed to initialize sdl_ttf: ", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	fmt.printfln("Creating app")
	app := new(sup.App)
	app._context = context
	app.title = "Ex11"
	app.width = 400
	app.height = 200
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	appState^ = app
	app.font = sup.CreateFont("./assets/08-true-type-fonts/lazy.ttf", 14)
	app.text = new(sup.Text)
	app.text.color = sdl.Color{ 0xff, 0x00, 0x00, 0x00}
	app.text.font = app.font
	app.text.position = sdl.FRect{ 0, 0, 0, 0}
	app.text.text = "Hello World"

	if app.font == nil { 
		fmt.printfln("Failed to load font")
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
    appState := (^sup.App)(appState)
	context = appState._context
	sdl.SetRenderDrawColor(appState.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(appState.renderer)
	sdl.SetRenderDrawColor(appState.renderer, 0xFF, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	buff: [256]u8
	appState.text.text = fmt.bprintf(buff[:], "Milliseconds since timer start: %d", sup.GetTicks(&appState.timer))
	if !sup.UpdateText(appState.renderer, appState.text) { 
		fmt.printfln("Failed to update text")
	}
	sup.RenderText(appState, appState.text)
	sdl.RenderPresent(appState.renderer)
	return sdl.AppResult.CONTINUE
}

AppEvent :: proc "c" (appState: rawptr, event:^sdl.Event) -> sdl.AppResult { 
	appState := (^sup.App)(appState)
	context = (^sup.App)(appState)._context
	#partial switch (event.type) { 
	case sdl.EventType.QUIT:
		return sdl.AppResult.SUCCESS
	case sdl.EventType.KEY_DOWN:
		#partial switch(event.key.scancode) { 
		case sdl.Scancode.Q:
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.SPACE:
			sup.ToggleTimer(&appState.timer)
		case sdl.Scancode.P:
			sup.TogglePauseTimer(&appState.timer)
		}
	}

	return sdl.AppResult.CONTINUE
}

AppQuit :: proc "c" (appState: rawptr, result: sdl.AppResult) { 
	appState := (^sup.App)(appState)
	context = appState._context
	fmt.printfln("Closing %s with result %v", appState.title, result)
	sdl_ttf.Quit()
	sdl.Quit()
}
main :: proc() { 
	argv :cstring = ""
	sdl.EnterAppMainCallbacks(0, &argv, AppInit, AppIterate, AppEvent, AppQuit)
}
