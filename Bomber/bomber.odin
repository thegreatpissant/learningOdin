package bomber

import "base:runtime"
import "core:fmt"
import "core:mem"
import sup "sup"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

FrameRate :: 60
track: mem.Tracking_Allocator

AppInit :: proc "c" (appState: ^rawptr, argc: i32, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	fmt.printfln("Initialize SDL")
	if !sdl.Init({.VIDEO , .AUDIO}) {
		fmt.printfln("Failed to initialize SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	if !sdl.HideCursor() { 
		fmt.printfln("Failed to hide mouse cursor: %s", sdl.GetError())
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
	sup.SetTargetFPS(&app.fps, FrameRate)
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

	fmt.printfln("Initialize Audio")
	fmt.printfln("Initialize Audio - DONE")

	fmt.printfln("Initialize Actors")
	assetScale :: 1.75

	app.bomber = new(sup.Bomber)
	if !sup.LoadTexture(app, "./assets/bomber/bomber.png", &app.bomber.texture) { 
		fmt.printfln("Failed to load bomber texture: %s", sdl.GetError())
	}
	app.bomber.width = (f32(app.bomber.texture.frameWidth) / 4) / assetScale
	app.bomber.height = (f32(app.bomber.texture.height) / 4) / assetScale
	app.bomber.spawnTimer.tickDelay = 500000000
	app.bomber.direction = 1
	app.bomber.speed = app.bomber.width
	sup.StartTimer(&app.bomber.spawnTimer)
	app.bomber.position.x = f32(app.width / 2)
	app.bomber.position.y = app.bomber.height 
	//  Bomb spawn point
	app.bomber.spawnPoint.x = app.bomber.width / 2
	app.bomber.spawnPoint.y = app.bomber.height

	bombTexture :^sup.Texture 
	if !sup.LoadTexture(app, "./assets/bomber/bomb.png", &bombTexture) { 
		fmt.printfln("Failed to load bomb texture: %s", sdl.GetError())
	}
	for i in 0..=10 { 
		bomb :^sup.Bomb= new(sup.Bomb)
		bomb.texture = bombTexture
		bomb.enabled = false
		bomb.position.x = f32(app.width / 2)
		bomb.position.y = f32(app.width / 3 * 2)
		bomb.width = (f32(bomb.texture.frameWidth) / 5 ) / assetScale
		bomb.height = (f32(bomb.texture.height) / 5 ) / assetScale
		bomb.speed = f32(bomb.height) * 2
		append(&app.bombs, bomb)
	}

	app.buckets = new(sup.Buckets)
	app.buckets.position.x = f32(app.width) / 2
	app.buckets.position.y = f32(app.height) / 2
	bucketTexture : ^sup.Texture
	if !sup.LoadTexture(app, "./assets/bomber/bucket.png", &bucketTexture) { 
		fmt.printfln("Failed to load bucket texture: %s", sdl.GetError())
	}
	for i in 0..<len(app.buckets.buckets) { 
		bucket := new(sup.Bucket)
		bucket.texture = bucketTexture
		bucket.width = (f32(bucket.texture.frameWidth) / 5 ) / assetScale
		bucket.height = (f32(bucket.texture.height) / 5 ) / assetScale * .7
		bucket.position.x = 0
		bucket.position.y = app.buckets.position.y + f32(i) * bucket.height  + f32(i) * bucket.height * .7
		bucket.enabled = true
		app.buckets.buckets[i] =  bucket
	}

	app.player = new(sup.Player)
	app.player.points = 0
	fmt.printfln("Initialize Actors - DONE")

	return sdl.AppResult.CONTINUE
}

UpdateScene :: proc(app:^sup.App, deltaTime:f32) { 
	sup.UpdateBomber(app.bomber, app.bombs, deltaTime)
	sup.UpdateBombs(app.bombs, deltaTime)
	sup.UpdateBuckets(app.buckets)
}

BISCOTTI :: sdl.Color{ 0xe3, 0xc5, 0x65, 0xff }

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	context = runtime.default_context()
	// --> INPUT
	// Init
	app := (^sup.App)(app)
	sup.StartFrame(&app.fps)
	// Update objects
	buf: [256]u8
	app.text.text = fmt.bprintf(buf[:], "%v fps", app.fps.fps)
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	// fmt.printfln("app.fps.delta: %v, sdl.NS_PER_SECOND: %v deltaTime: %v", app.fps.delta, sdl.NS_PER_SECOND, deltaTime)

	// Actors
	UpdateScene(app, deltaTime)
	// Audio

	// Render
	sdl.SetRenderDrawColor(app.renderer, BISCOTTI.r, BISCOTTI.g, BISCOTTI.b, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.UpdateText(app.renderer, app.text)
	sup.RenderText(app, app.text, &app.text.position)
	sdl.SetRenderDrawBlendMode(app.renderer, sdl.BLENDMODE_BLEND)
	sup.RenderTexture(
		app.bomber.texture, 
		sup.GetSrcRect(app.bomber.texture), 
		sdl.FRect{ app.bomber.position.x, app.bomber.position.y, app.bomber.width, app.bomber.height},
		app, 
		0,
		sdl.FPoint{ 0,0}
	)
	// RenderBombs
	for bomb in app.bombs { 
		if bomb.enabled { 
			sup.RenderTexture(
				bomb.texture,
				sup.GetSrcRect(bomb.texture),
				sdl.FRect{bomb.position.x, bomb.position.y, bomb.width, bomb.height},
				app,
				0, sdl.FPoint{ 0, 0}
			)
		}
	}	

	// RenderBuckets
	for bucket in app.buckets.buckets { 
		if bucket.enabled { 
			sup.RenderTexture(
				bucket.texture,
				sup.GetSrcRect(bucket.texture),
				sdl.FRect{bucket.position.x, bucket.position.y, bucket.width, bucket.height},
				app,
				0, sdl.FPoint{ 0, 0}
			)
		}
	}

	/* Issue:
	   Game Rate and Frame Rate are not independent.
		droping the initial frame rate lower than the length of a 
		timer, ex 1fps will cause issues.  With this "Game" it is 
		not of consequence 
	*/
	sdl.RenderPresent(app.renderer)
	sup.EndFrame(&app.fps)
	return sdl.AppResult.CONTINUE
}

initialMouse := true

AppEvent :: proc "c" (app: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	context = runtime.default_context()
	app := (^sup.App)(app)
	offset :: 10
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
	case sdl.EventType.WINDOW_MOUSE_ENTER:
		initialMouse = true
	case sdl.EventType.MOUSE_MOTION:
		if initialMouse { 
			initialMouse = false
			app.buckets.position.x = event.motion.x
		} else { 
			app.buckets.position.x += event.motion.xrel
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
