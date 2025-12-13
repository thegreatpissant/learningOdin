package ex11

import "core:fmt"
import "base:runtime"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"
import sup "sup"

prevTick :u64= 0
vsync :i32= 0
frame := 0
ToggleVSync ::proc(app:^sup.App) { 
	if vsync == 0 { 
		vsync = 1
	} else { 
		vsync = 0
	}
	if !sdl.SetRenderVSync(app.renderer, vsync){ 
		fmt.printfln("failed to set vsync")
	}
}

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
	app.title = "Ex12"
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
	app.targetFPS = 30
	app.targetFPSns = sdl.NS_PER_SECOND / app.targetFPS

	if app.font == nil { 
		fmt.printfln("Failed to load font")
		return sdl.AppResult.FAILURE
	}
	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, { }, &app.window, &app.renderer) { 
		fmt.printfln("Failed to CreateWindowAndRenderer SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	fmt.printfln("Initializing SDL - DONE")
	prevTick = sdl.GetPerformanceCounter()
	app.timer.prevTick = prevTick
	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (appState: rawptr) -> sdl.AppResult { 
	curTick := sdl.GetPerformanceCounter()
    appState := (^sup.App)(appState)
	context = appState._context
	sdl.SetRenderDrawColor(appState.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(appState.renderer)
	sdl.SetRenderDrawColor(appState.renderer, 0xFF, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	elapsed := curTick - prevTick
	fps := elapsed > 0 ? sdl.NS_PER_SECOND / elapsed : 0
	fmt.printfln("frame: %5d, elapsed: %10v, curTick: %10v, prevTick: %10v, fps: %10v", frame, elapsed, curTick, prevTick, fps)
	frame += 1
	prevTick = curTick
	buff: [256]u8
	appState.text.text = fmt.bprintf(buff[:], "Target: %v, FPS: %v, Diff: %v", appState.targetFPS, fps, appState.targetFPS > fps ? appState.targetFPS - fps: 0)
	if !sup.UpdateText(appState.renderer, appState.text) { 
		fmt.printfln("Failed to update text")
	}
	sup.RenderText(appState, appState.text)
	sdl.RenderPresent(appState.renderer)
	frameElapsed := sdl.GetPerformanceCounter() - curTick
	delay := frameElapsed > appState.targetFPSns ? 0 : appState.targetFPSns - frameElapsed
	sdl.DelayPrecise(delay)
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
		case sdl.Scancode.V:
			ToggleVSync(appState)
		case sdl.Scancode.PAGEUP:
			appState.targetFPS += 10
			appState.targetFPSns = sdl.NS_PER_SECOND / appState.targetFPS
		case sdl.Scancode.UP:
			appState.targetFPS += 1
			appState.targetFPSns = sdl.NS_PER_SECOND / appState.targetFPS
		case sdl.Scancode.PAGEDOWN:
			appState.targetFPS -= 10
			appState.targetFPSns = sdl.NS_PER_SECOND / appState.targetFPS
		case sdl.Scancode.DOWN:
			appState.targetFPS -= 1
			appState.targetFPSns = sdl.NS_PER_SECOND / appState.targetFPS
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
