package ex13

import "base:runtime"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

track: mem.Tracking_Allocator
menuText_1: ^sup.Text
menuText_2: ^sup.Text
menuText_3: ^sup.Text
beatSound : ^sup.Audio
audioStream : ^sdl.AudioStream

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
	menuText_1 = new(sup.Text)
	menuText_1.color = sdl.Color{0xff, 0xff, 0xff, 0x00}
	menuText_1.font = app.font
	menuText_1.position = sdl.FPoint{0,20}
	menuText_2 = new(sup.Text)
	menuText_2.color = sdl.Color{0xff, 0xff, 0xff, 0x00}
	menuText_2.font = app.font
	menuText_2.position = sdl.FPoint{0,50}
	menuText_3 = new(sup.Text)
	menuText_3.color = sdl.Color{0xff, 0xff, 0xff, 0x00}
	menuText_3.font = app.font
	menuText_3.position = sdl.FPoint{0,80}
	menuText_1.text = "Press 1, 2, 3, or 4 to \nplay sound effect"
	menuText_2.text = "Press 9 to play or pause\n the music"
	menuText_3.text = "Press 0 to stop the music"
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
	sup.UpdateText(app.renderer, menuText_1)
	sup.UpdateText(app.renderer, menuText_2)
	sup.UpdateText(app.renderer, menuText_3)
	fmt.printfln("Loading Textures - DONE")

	fmt.printfln("Loading audio")
	beatSound = new(sup.Audio)
	beatSound.spec = new(sdl.AudioSpec)
	if !sdl.LoadWAV("./assets/sounds/beat.wav", beatSound.spec, &beatSound.buf, &beatSound.len) { 
		fmt.printfln("Failed to load sound: %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	audioStream = sdl.OpenAudioDeviceStream(sdl.AUDIO_DEVICE_DEFAULT_PLAYBACK, beatSound.spec, nil, nil)
	if audioStream == nil { 
		fmt.printfln("Failed to create stream: %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	sdl.ResumeAudioStreamDevice(audioStream)
	fmt.printfln("Loading audio - DONE")
	return sdl.AppResult.CONTINUE
}

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
	if sdl.GetAudioStreamQueued(audioStream) < i32(beatSound.len) { 
		sdl.PutAudioStreamData(audioStream, beatSound.buf, i32(beatSound.len))
	}

	// Render
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.UpdateText(app.renderer, app.text)
	sup.RenderText(app, app.text, &app.text.position)
	sup.RenderText(app, menuText_1, &menuText_1.position)
	sup.RenderText(app, menuText_2, &menuText_2.position)
	sup.RenderText(app, menuText_3, &menuText_3.position)
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

