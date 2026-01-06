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
	app.playerScoreText = new(sup.Text)
	app.playerScoreText.color = sdl.Color{0xff, 0x00, 0x00, 0x00}
	app.playerScoreText.font = app.font
	app.playerScoreText.position = sdl.FPoint{ f32(app.width / 2), 0}
	sup.SetTargetFPS(&app.fps, FrameRate)
	app.fps.frameStartTicks = sdl.GetPerformanceCounter()
	app.gameState = sup.GameState.START
	app.level = 1
	app.bombBurstTimer.tickDelay = .3 * sdl.NS_PER_SECOND
	app.nextLevelTimer.tickDelay = 2 * sdl.NS_PER_SECOND
	fmt.printfln("Initialize App - DONE")

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(app.title, app.width, app.height, {}, &app.window, &app.renderer) {
		fmt.printfln("Failed to create window and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	if !sdl.SetWindowMouseGrab(app.window, true) { 
		fmt.printfln("Failed to grab the mouse cursor: %s", sdl.GetError())
	}
	// sdl.SetRenderLogicalPresentation(app.renderer, app.width, app.height, sdl.RendererLogicalPresentation.LETTERBOX)
	sdl.SetRenderLogicalPresentation(app.renderer, app.width, app.height, sdl.RendererLogicalPresentation.INTEGER_SCALE)
	fmt.printfln("Initialize Window - DONE")

	fmt.printfln("== Loading Textures")
	groundTexture : ^sup.Texture
	if !sup.LoadTexture(app, "./assets/bomber/ground.png", &groundTexture) { 
		fmt.printfln("Failed to load ground texture: %s", sdl.GetError())
	}
	bomberTexture : ^sup.Texture
	if !sup.LoadTexture(app, "./assets/bomber/bomber.png", &bomberTexture) { 
		fmt.printfln("Failed to load bomber texture: %s", sdl.GetError())
	}
	bombIdleTexture :^sup.Texture 
	if !sup.LoadTexture(app, "./assets/bomber/bomb.png", &bombIdleTexture, 1) { 
		fmt.printfln("Failed to load bomb texture: %s", sdl.GetError())
	}
	bombBlowUpTexture:^sup.Texture
	if !sup.LoadTexture(app, "./assets/bomber/bomb-sheet.png", &bombBlowUpTexture, 4) { 
		fmt.printfln("Failed to load bomb texture: %s", sdl.GetError())
	}

	bucketTexture : ^sup.Texture
	if !sup.LoadTexture(app, "./assets/bomber/bucket.png", &bucketTexture) { 
		fmt.printfln("Failed to load bucket texture: %s", sdl.GetError())
	}
	fmt.printfln("== Loading Textures - DONE")

	fmt.printfln("== Initialize Audio")
	fmt.printfln("== Initialize Audio - DONE")

	fmt.printfln("== Initialize Actors")
	assetScale :: 1.75

	//  Bomber
	app.groundTexture = groundTexture
	app.bomber = new(sup.Bomber)
	app.bomber.texture = bomberTexture
	app.bomber.width = (f32(app.bomber.texture.frameWidth) / 4) / assetScale
	app.bomber.height = (f32(app.bomber.texture.height) / 4) / assetScale
	app.bomber.speed = app.bomber.width
	sup.StartTimer(&app.bomber.spawnTimer)
	app.bomber.position.y = app.bomber.height 
	//  Bomber's Bomb spawn point
	app.bomber.spawnPoint.x = app.bomber.width / 2
	app.bomber.spawnPoint.y = app.bomber.height
	//  Bombs
	for i in 0..<len(app.bombs) { 
		bomb :^sup.Bomb= new(sup.Bomb)
		app.bombs[i] = bomb
		bomb.enabled = false
		bomb.idleAnimation = new(sup.Animation)
		bomb.idleAnimation.texture = bombIdleTexture
		bomb.blowUpAnimation = new(sup.Animation)
		bomb.blowUpAnimation.texture = bombBlowUpTexture
		bomb.width = (f32(bomb.idleAnimation.texture.frameWidth) / 5 ) / assetScale
		bomb.height = (f32(bomb.idleAnimation.texture.height) / 5 ) / assetScale
	}
	//  Buckets
	app.buckets = new(sup.Buckets)
	app.buckets.position.y = f32(app.height) / 2
	for i in 0..<len(app.buckets.buckets) { 
		bucket := new(sup.Bucket)
		bucket.texture = bucketTexture
		bucket.height = (f32(bucket.texture.height) / 5 ) / assetScale * .7
		bucket.position.x = 0
		bucket.position.y = app.buckets.position.y + f32(i) * bucket.height + f32(i) * bucket.height * .7
		bucket.collider.rect.x = bucket.position.x
		bucket.collider.rect.y = bucket.position.y
		bucket.collider.rect.h = bucket.height / 5
		app.buckets.buckets[i] =  bucket
	}
	//  Player
	app.player = new(sup.Player)
	//  Ground
	app.groundCollider = new(sup.BoxCollider)
	app.groundCollider.rect = { 0, f32(app.height) - 50, f32(app.width), f32(50)}
	fmt.printfln("Initialize Actors - DONE")

	InitPlayer(app)
	InitBomber(app)

	return sdl.AppResult.CONTINUE
}

InitPlayer :: proc(app:^sup.App) { 
	app.player.score = 0
	app.player.lives = 1
}

InitBomber :: proc(app:^sup.App) { 
	assetScale :f32= 1 / 1.75

	// Level specific
	bucketWidth : f32 
	bombSpeed :f32 
	bomberSpeed :f32
	bomberSpawnTimer :u64
	bombCount :int
	switch app.level { 
	case 1:
		bucketWidth = (f32(app.buckets.buckets[0].texture.frameWidth) / 3 ) * assetScale
		bombSpeed = f32(app.bombs[0].height) * 2 * f32(app.level)
		bomberSpeed = app.bomber.width * 2 * f32(app.level)
		bombCount = 15
		bomberSpawnTimer = 700000000 
	case 2:
		bucketWidth = (f32(app.buckets.buckets[0].texture.frameWidth) / 3 ) * assetScale
		bombSpeed = f32(app.bombs[0].height) * 2 * f32(app.level)
		bomberSpeed = app.bomber.width * 2 * f32(app.level)
		bombCount = 15
		bomberSpawnTimer = 500000000 
	case 3:
		bucketWidth = (f32(app.buckets.buckets[0].texture.frameWidth) / 3 ) * assetScale
		bombSpeed = f32(app.bombs[0].height) * 2 * f32(app.level)
		bomberSpeed = app.bomber.width * 2 * f32(app.level)
		bombCount = 15
		bomberSpawnTimer = 300000000
	case:
		bucketWidth = (f32(app.buckets.buckets[0].texture.frameWidth) / 3 ) * assetScale
		bombSpeed = f32(app.bombs[0].height) * 2 * f32(app.level)
		bomberSpeed = app.bomber.width * 2 * f32(app.level)
		bombCount = 15
		bomberSpawnTimer = 100000000
	}
	app.bomber.bombsCaught = 0
	app.bomber.direction = 1
	app.bomber.position.x = f32(app.width / 2)
	app.bomber.spawnTimer.tickDelay = bomberSpawnTimer
	app.bomber.speed = bomberSpeed
	app.bomber.bombCount = bombCount
	for bomb in app.bombs { 
		bomb.enabled = false
		bomb.blowingUp = false
		bomb.animation = bomb.idleAnimation
		bomb.speed = bombSpeed
	}
	app.bomber.nextBomb = app.bomber.bombCount
	app.buckets.position.x = f32(app.width) / 2
	for bucket in app.buckets.buckets { 
		bucket.width = bucketWidth
		bucket.enabled = true
	}
	initialMouse = true
	sup.StartTimer(&app.bomber.spawnTimer)
}

RenderLevelSuccess :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Get Ready for the Next Level")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition : sup.Position
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2 - app.fpsText.texture.texture.h )
	sup.RenderText(app, app.fpsText, &textPosition)
}

RenderEndScreen :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Game Over")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition : sup.Position
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2 - app.fpsText.texture.texture.h )
	sup.RenderText(app, app.fpsText, &textPosition)
	app.fpsText.text = fmt.bprintf(buf[:], "Play Again? (Y / N)")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y = f32(app.height /2 + app.fpsText.texture.height)
	sup.RenderText(app, app.fpsText, &textPosition)
}

RenderPauseScreen :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Continue? (Y / N)")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition : sup.Position
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2)
	sup.RenderText(app, app.fpsText, &textPosition)
}

RenderRetryScreen :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Press any key to Retry")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition : sup.Position
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2)
	sup.RenderText(app, app.fpsText, &textPosition)
}

RenderStartScreen :: proc(app:^sup.App) { 
	buf: [256]u8
	app.fpsText.text = fmt.bprintf(buf[:], "Click mouse to start")
	sup.UpdateText(app.renderer, app.fpsText)
	textPosition : sup.Position
	textPosition.x = f32(app.width / 2 - app.fpsText.texture.texture.w / 2)
	textPosition.y =  f32(app.height / 2)
	sup.RenderText(app, app.fpsText, &textPosition)
}

UpdateLevelLost :: proc(app:^sup.App, deltaTime:f32) { 
	//  iterate through the bombs and blow them up
	if sup.Ticked(&app.bombBurstTimer) { 
		for i := len(app.bombs) - 1; i >= 0; i -=1 { 
			if app.bombs[i].enabled && !app.bombs[i].blowingUp { 
				sup.BlowUpBomb(app.bombs[i])
				break
			}
		}
	} 
	//  Iterate bomb state
	for bomb in app.bombs { 
		if bomb.blowingUp { 
			if sup.Ticked(&bomb.blowUpTimer) { 
				bomb.blowingUp = false
				bomb.enabled = false
			}
		} 
	}

	//  Are all the bombs blown up?
	for bomb in app.bombs { 
		if bomb.enabled { 
			return
		}
	}

	// After last bomb blows up
	sup.StopTimer(&app.bombBurstTimer)
	if app.player.lives < 0 { 
		app.gameState = sup.GameState.END
	} else { 
		InitBomber(app)
		app.gameState = sup.GameState.RETRYSTART
	}
}

UpdateNextLevel :: proc (app:^sup.App, deltaTime:f32) { 

	if sup.Ticked(&app.nextLevelTimer) { 
		app.level += 1
		app.gameState = sup.GameState.RUN
		InitBomber(app)
	}
}

UpdateGamePlay :: proc(app:^sup.App, deltaTime:f32) { 
	// Physics?
	sup.UpdateBomber(app.bomber, app.bombs, deltaTime)
	sup.UpdateBombs(app.bombs, deltaTime)
	sup.UpdateBuckets(app.buckets)

	// Collisions
	//  bombs with botom of the game board
	for bomb in app.bombs { 
		if !bomb.enabled { 
				continue
		}	
		if sup.Collides(&bomb.collider.rect, &app.groundCollider.rect) { 
			app.gameState = sup.GameState.LOSELEVEL
			sup.StartTimer(&app.bombBurstTimer)
			app.bombBurstTimer.startTicks = 0
			app.player.lives -= 1
			for bomb in app.bombs{ 
				bomb.speed = 0
			}
			return
		}

		//  bombs with the buckets
		for bucket in app.buckets.buckets { 
			if sup.Collides(&bucket.collider.rect, &bomb.collider.rect) { 
				app.player.score += 10
				bomb.enabled = false
				app.bomber.bombsCaught += 1
				continue
			}
		}
	}

	if app.bomber.bombsCaught >= app.bomber.bombCount { 
		app.gameState = sup.GameState.NEXTLEVEL
		sup.StartTimer(&app.nextLevelTimer)
	}	

	//  buckets with the edge of the app
	if app.buckets.position.x < 0 { 
		app.buckets.position = 0
	}
	maxWidth := f32(app.width) - (app.buckets.buckets[0].width)
	if app.buckets.position.x > maxWidth { 
		app.buckets.position.x = maxWidth
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
			sup.UpdateAnimation(bomb.animation, app.fps.delta)
			sup.RenderTexture(
				bomb.animation.texture,
				sup.GetSrcRectForAnimation(bomb.animation),
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

	// Ground
	sup.RenderTexture(
		app.groundTexture,
		sup.GetSrcRect(app.groundTexture),
		app.groundCollider.rect,
		app,
		0, sdl.FPoint{ 0, 0}
	)
		
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
	sup.UpdateText(app.renderer, app.fpsText)
	app.playerScoreText.text = fmt.bprintf(buf[:], "Level: %d  Score: %d   lives: %d", app.level, app.player.score, app.player.lives < 0?0:app.player.lives)
	sup.UpdateText(app.renderer, app.playerScoreText)
	app.playerScoreText.position.x = f32(app.width / 2 - app.playerScoreText.texture.texture.w / 2)
	deltaTime := f32(app.fps.delta) / f32(sdl.NS_PER_SECOND)
	// fmt.printfln("app.fps.delta: %v, sdl.NS_PER_SECOND: %v deltaTime: %v", app.fps.delta, sdl.NS_PER_SECOND, deltaTime)

	// Actors
	#partial switch app.gameState { 
	case sup.GameState.RUN:
		UpdateGamePlay(app, deltaTime)
	case sup.GameState.LOSELEVEL:
		UpdateLevelLost(app, deltaTime)
	case sup.GameState.NEXTLEVEL:
		UpdateNextLevel(app, deltaTime)
	}
	// Audio

	// Render
	sdl.SetRenderDrawColor(app.renderer, BISCOTTI.r, BISCOTTI.g, BISCOTTI.b, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.RenderText(app, app.fpsText, &app.fpsText.position)
	sup.RenderText(app, app.playerScoreText, &app.playerScoreText.position)

	#partial switch app.gameState { 
	case sup.GameState.RUN:
		fallthrough
	case sup.GameState.LOSELEVEL:
		RenderGamePlay(app)
	case sup.GameState.NEXTLEVEL:
		RenderLevelSuccess(app)
	case sup.GameState.START:
		RenderStartScreen(app)
	case sup.GameState.RETRYSTART:
		RenderRetryScreen(app)
	case sup.GameState.PAUSE:
		RenderPauseScreen(app)
	case sup.GameState.END:
		RenderEndScreen(app)
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
		fallthrough
	case sup.GameState.LOSELEVEL:
		fallthrough
	case sup.GameState.NEXTLEVEL:
		return GamePlayEvent(app, event)
	case sup.GameState.RETRYSTART:
		fallthrough
	case sup.GameState.START:
		return StartEvent(app, event)
	case sup.GameState.PAUSE:
		return PauseEvent(app, event)
	case sup.GameState.END:
		return EndEvent(app, event)
	}
	return sdl.AppResult.CONTINUE
}

EndEvent :: proc(app:^sup.App, event: ^sdl.Event) -> sdl.AppResult { 
	#partial switch (event.type) {
	case sdl.EventType.KEY_DOWN:
		#partial switch (event.key.scancode) { 
		case sdl.Scancode.N:
			app.gameState = sup.GameState.QUIT
			return sdl.AppResult.SUCCESS
		case sdl.Scancode.ESCAPE:
			fallthrough	
		case sdl.Scancode.Y:
			InitPlayer(app)
			InitBomber(app)
			app.gameState = sup.GameState.START
		}
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
	case sdl.EventType.MOUSE_BUTTON_DOWN:
		app.gameState = sup.GameState.RUN
	}
	return sdl.AppResult.CONTINUE
}

GamePlayEvent :: proc(app:^sup.App, event: ^sdl.Event) -> sdl.AppResult { 
	// fmt.printfln("event: %v ", event.motion)
	// sdl.ConvertEventToRenderCoordinates(app.renderer, event)
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
