package ex17

import "base:runtime"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:strings"
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
	app.title = "ex17"
	app.width = 640
	app.height = 480
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	app.font = sup.CreateFont("./assets/08-true-type-fonts/lazy.ttf", 22)
	app.text = new(sup.Text)
	app.text.color = sdl.Color{0xff, 0x00, 0x00, 0x00}
	app.text.font = app.font
	app.text.position = sdl.FPoint{0, 0}
	app.userText = ""
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
	fmt.printfln("Loading Textures - DONE")

	fmt.printfln("StartText input")
	if !sdl.StartTextInput(app.window) { 
		fmt.printfln("Failed to start TextInput: %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}

	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	// ^^INPUT
	app := (^sup.App)(app)
	context = runtime.default_context()
	sup.StartFrame(&app.fps)
	// Update objects

	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)

	// Render
	sdl.SetRenderDrawColor(app.renderer, 0xff, 0xff, 0xff, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	buf: [256]u8
	app.text.text = fmt.bprintf(buf[:], "%v fps", app.fps.fps)
	app.text.position.x = 0
	app.text.position.y = 0
	sup.UpdateText(app.renderer, app.text)
	sup.RenderText(app, app.text, &app.text.position)
	
	app.text.text = fmt.bprintf(buf[:], "Enter Text:\n %s ", app.userText)
	sup.UpdateText(app.renderer, app.text)
	app.text.position.x = f32(app.width) * 0.5 - f32(app.text.texture.texture.w) * 0.5
	app.text.position.y = f32(app.height) * 0.5 - f32(app.text.texture.texture.h)
	sup.RenderText(app, app.text, &app.text.position)

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
		case sdl.Scancode.ESCAPE:
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.PAGEUP:
			sup.SetTargetFPS(&app.fps, app.fps.targetFPS + 10)
		}
		switch (event.key.key) { 
		case sdl.K_BACKSPACE:
			app.userText = app.userText[:len(app.userText) > 0?len(app.userText) - 1:0]
		case sdl.K_C:
			fmt.printfln("Copy clipboard")
			if sdl.GetModState() & sdl.KMOD_LCTRL == sdl.KMOD_LCTRL { 
				sdl.SetClipboardText(strings.clone_to_cstring(app.userText[:]))
				fmt.printfln("\tcopied user buffer: %s", app.userText)
			}
		case sdl.K_V:
			fmt.printfln("Paste clipboard")
			if sdl.GetModState() & sdl.KMOD_LCTRL == sdl.KMOD_LCTRL { 
				clipboardData := sdl.GetClipboardText()
				app.userText = string(cstring(clipboardData))
				fmt.printfln("\tclipboard Data: %s", clipboardData)
			}
		}
	case sdl.EventType.TEXT_INPUT:
		inputChar := strings.to_upper(string(event.text.text))
		if !((sdl.GetModState() & sdl.KMOD_LCTRL == sdl.KMOD_LCTRL) && 
			(inputChar[0] == 'C' || inputChar[0] == 'V')) { 
			fmt.printfln("Filter ctrl+cmd's from text input")
			a:= [?]string {app.userText , string(event.text.text)[:1]}
			app.userText = strings.concatenate(a[:])
		}
		fmt.printfln("inputChar: %v", inputChar)
	}
	fmt.printfln("User input text: %s", app.userText)

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

