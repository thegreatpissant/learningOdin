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
	app.fpsText = new(sup.Text)
	app.fpsText.color = sdl.Color{0xff, 0x00, 0x00, 0x00}
	app.fpsText.font = app.font
	app.fpsText.position = sdl.FPoint{0, 0}
	sup.SetTargetFPS(&app.fps, FrameRate)
	app.fps.frameStartTicks = sdl.GetPerformanceCounter()
	app.gameState = sup.GameState.START
	app.level = 1
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
	app.bomber.speed = app.bomber.width
	sup.StartTimer(&app.bomber.spawnTimer)
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
		bomb.collider.rect.x = bomb.position.x
		bomb.collider.rect.y = bomb.position.y
		bomb.collider.rect.w = bomb.width
		bomb.collider.rect.h = bomb.height
		append(&app.bombs, bomb)
	}

	app.buckets = new(sup.Buckets)
	app.buckets.position.y = f32(app.height) / 2
	bucketTexture : ^sup.Texture
	if !sup.LoadTexture(app, "./assets/bomber/bucket.png", &bucketTexture) { 
		fmt.printfln("Failed to load bucket texture: %s", sdl.GetError())
	}
	for i in 0..<len(app.buckets.buckets) { 
		bucket := new(sup.Bucket)
		bucket.texture = bucketTexture
		bucket.height = (f32(bucket.texture.height) / 5 ) / assetScale * .7
		bucket.position.x = 0
		bucket.position.y = app.buckets.position.y + f32(i) * bucket.height  + f32(i) * bucket.height * .7
		bucket.collider.rect.x = bucket.position.x
		bucket.collider.rect.y = bucket.position.y
		bucket.collider.rect.h = bucket.height / 5
		app.buckets.buckets[i] =  bucket
	}
	app.player = new(sup.Player)
	InitPlayer(app)

	app.groundCollider = new(sup.BoxCollider)
	app.groundCollider.rect = { 0, f32(app.height) - 50, f32(app.width), f32(app.height)}
	fmt.printfln("Initialize Actors - DONE")

	InitBomberLevel(app)

	return sdl.AppResult.CONTINUE
}

InitPlayer :: proc(app:^sup.App) { 
	app.player.points = 0
}

InitBomberLevel :: proc(app:^sup.App) { 
	assetScale :f32= 1.75
	bucketWidth : f32 = (f32(app.buckets.buckets[0].texture.frameWidth) / 5 ) / assetScale
	bombSpeed :f32 = f32(app.bombs[0].height) * 2
	bomberSpeed :f32 = app.bomber.speed
	bomberSpawnTimer :u64 = 500000000

	app.bomber.direction = 1
	app.bomber.position.x = f32(app.width / 2)
	app.bomber.spawnTimer.tickDelay = bomberSpawnTimer
	for bomb in app.bombs { 
		bomb.speed = bombSpeed
	}

	app.buckets.position.x = f32(app.width) / 2
	for bucket in app.buckets.buckets { 
		bucket.width = bucketWidth
		bucket.enabled = true
	}
}
RenderPauseScreen :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Continue? (Y / N)")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition := new(sup.Position)
	defer free(textPosition)
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2)
	sup.RenderText(app, app.fpsText, textPosition)
}

RenderStartScreen :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Press any key to start")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition := new(sup.Position)
	defer free(textPosition)
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2)
	sup.RenderText(app, app.fpsText, textPosition)
}

UpdateGamePlay :: proc(app:^sup.App, deltaTime:f32) { 
	// Physics?
	sup.UpdateBomber(app.bomber, app.bombs, deltaTime)
	sup.UpdateBombs(app.bombs, deltaTime)
	sup.UpdateBuckets(app.buckets)

	// Collisions
	//  bombs with botom of the game board
	for bomb in app.bombs { 
		if sup.Collides(&bomb.collider.rect, &app.groundCollider.rect) { 
			bomb.enabled = false
		}
	}
	//  bombs with the buckets
	for bomb in app.bombs { 
		if !bomb.enabled { 
			continue
		}
		for bucket in app.buckets.buckets { 
			if sup.Collides(&bucket.collider.rect, &bomb.collider.rect) { 
				bomb.enabled = false
				continue
			}
		}
	}
}

RenderGamePlay :: proc(app:^sup.App){ 
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

	sdl.SetRenderDrawColor(app.renderer, 0xff, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderRect(app.renderer, &app.groundCollider.rect)
	for bomb in app.bombs { 
		if bomb.enabled { 
			sdl.RenderRect(app.renderer, &bomb.collider.rect)
		}
	}
	for bucket in app.buckets.buckets { 
		sdl.RenderRect(app.renderer, &bucket.collider.rect)	
	}

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
	app.fpsText.text = fmt.bprintf(buf[:], "%v fps", app.fps.fps)
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	// fmt.printfln("app.fps.delta: %v, sdl.NS_PER_SECOND: %v deltaTime: %v", app.fps.delta, sdl.NS_PER_SECOND, deltaTime)

	// Actors
	#partial switch app.gameState { 
	case sup.GameState.RUN:
		UpdateGamePlay(app, deltaTime)
	}
	// Audio

	// Render
	sdl.SetRenderDrawColor(app.renderer, BISCOTTI.r, BISCOTTI.g, BISCOTTI.b, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.UpdateText(app.renderer, app.fpsText)
	sup.RenderText(app, app.fpsText, &app.fpsText.position)

	#partial switch app.gameState { 
	case sup.GameState.RUN:
		RenderGamePlay(app)
	case sup.GameState.START:
		RenderStartScreen(app)
	case sup.GameState.PAUSE:
		RenderPauseScreen(app)
	}

	sdl.RenderPresent(app.renderer)
	sup.EndFrame(&app.fps)
	return sdl.AppResult.CONTINUE
}

initialMouse := true

AppEvent :: proc "c" (app: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	context = runtime.default_context()
	app := (^sup.App)(app)
	offset :: 10
	// Global quit handle
   	#partial switch (event.type) {
	case sdl.EventType.QUIT:
		return sdl.AppResult.SUCCESS
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.Q:
			app.gameState = sup.GameState.QUIT
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.PAGEUP:
			sup.SetTargetFPS(&app.fps, app.fps.targetFPS + offset)
		}
	}

	//  GameState switch
	#partial switch (app.gameState) { 
	case sup.GameState.RUN:
		return GamePlayEvent(app, event)
	case sup.GameState.START:
		return StartEvent(app, event)
	case sup.GameState.PAUSE:
		return PauseEvent(app, event)
	}
	return sdl.AppResult.CONTINUE
}

PauseEvent :: proc(app:^sup.App, event: ^sdl.Event) -> sdl.AppResult { 
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) { 
		case sdl.Scancode.N:
			app.gameState = sup.GameState.QUIT
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.ESCAPE:
			fallthrough	
		case sdl.Scancode.Y:
			app.gameState = sup.GameState.RUN
		}
	}
	return sdl.AppResult.CONTINUE
}

StartEvent :: proc(app:^sup.App, event: ^sdl.Event) -> sdl.AppResult { 
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		app.gameState = sup.GameState.RUN
	}
	return sdl.AppResult.CONTINUE
}

GamePlayEvent :: proc(app:^sup.App, event: ^sdl.Event) -> sdl.AppResult { 
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) {
		case sdl.Scancode.ESCAPE:
			app.gameState = sup.GameState.PAUSE
			return sdl.AppResult.CONTINUE
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
