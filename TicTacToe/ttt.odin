package TicTacToe

import "core:fmt"
import "core:log"
import rand "core:math/rand"
import mem "core:mem"
import "core:strings"
import scaffolding "scaffolding"
import sdl "vendor:sdl3"
import sdl_ttf "vendor:sdl3/ttf"

CountDowner: u64
CountTime: u64

Winner: string

// Text
gameName: ^scaffolding.Text
startQuestion: ^scaffolding.Text
playerOneStart: ^scaffolding.Text
playerTwoStart: ^scaffolding.Text
thankYouForPlaying: ^scaffolding.Text
oTexture: ^sdl.Texture
xTexture: ^sdl.Texture

InitGame :: proc(app: ^scaffolding.App) {
	app.gameState = scaffolding.GameState.Start
	InitBoardRandomly(app)
	Winner = "None"
}

InitBoard :: proc(app: ^scaffolding.App) {
	for i in 0 ..< 3 {
		for j in 0 ..< 3 {
			app.board.board[i][j] = scaffolding.Cell.NONE
		}
	}
}

InitBoardRandomly :: proc(app: ^scaffolding.App) {
	cellA: []scaffolding.Cell = {
		scaffolding.Cell.PLAYER_X,
		scaffolding.Cell.PLAYER_O,
	}
	for i in 0 ..< 3 {
		for j in 0 ..< 3 {
			app.board.board[i][j] = rand.choice(cellA)
		}
	}
}

RenderCell :: proc(
	renderer: ^sdl.Renderer,
	cell: ^scaffolding.Cell,
	posx, posy, width, height: f32,
) {
	dstRect := sdl.FRect{posx, posy, width * 1.5, height * 1.5}
	#partial switch (cell^) {
	case .PLAYER_X:
		srcRect := sdl.FRect{0, 0, f32(xTexture.w), f32(xTexture.h)}
		sdl.RenderTexture(renderer, xTexture, &srcRect, &dstRect)
	case .PLAYER_O:
		srcRect := sdl.FRect{0, 0, f32(oTexture.w), f32(oTexture.h)}
		sdl.RenderTexture(renderer, oTexture, &srcRect, &dstRect)
	}
}

RenderCells :: proc(app: ^scaffolding.App) {
	padding: f32 = 20
	width := f32(app.width / 3)
	height := f32(app.height / 3)
	for i in 0 ..< 3 {
		for j in 0 ..< 3 {
			posx := f32(i) * width + padding / 2
			posy := f32(j) * height + padding / 2
			RenderCell(
				app.window.renderer,
				&app.board.board[i][j],
				posx,
				posy,
				width - padding,
				height - padding,
			)
		}
	}
}

RenderBoard :: proc(app: ^scaffolding.App) {
	sdl.SetRenderDrawColor(app.window.renderer, 0xff, 0x00, 0x00, 0xff)
	vert := f32(app.width / 3)
	height := f32(app.height / 3)
	if true {
		//  Vertical lines
		sdl.RenderLine(app.window.renderer, vert, 0, vert, height * 3)
		sdl.RenderLine(app.window.renderer, vert * 2, 0, vert * 2, height * 3)
		//  Horizontal lines
		sdl.RenderLine(app.window.renderer, 0, height, vert * 3, height)
		sdl.RenderLine(
			app.window.renderer,
			0,
			height * 2,
			vert * 3,
			height * 2,
		)
	}
}

GameStart :: proc(app: ^scaffolding.App) {
	event: sdl.Event
	quit := false

	for quit == false {
		sdl.zerop(&event)
		for sdl.PollEvent(&event) == true {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				app.gameState = scaffolding.GameState.UNKNOWN
				quit = true
			case sdl.EventType.KEY_DOWN:
				switch event.key.key {
				case sdl.K_N:
					app.gameState = scaffolding.GameState.End
					quit = true
				case sdl.K_Y:
					app.gameState = scaffolding.GameState.Playing
					quit = true
				}
			}
		}
		sdl.SetRenderTarget(app.window.renderer, app.board.texture)
		sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
		sdl.RenderClear(app.window.renderer)

		scaffolding.RenderText(app, gameName)

		sdl.SetRenderTarget(app.window.renderer, nil)
		sdl.RenderTexture(app.window.renderer, app.board.texture, nil, nil)
		sdl.RenderPresent(app.window.renderer)
	}
}

GameEnd :: proc(app: ^scaffolding.App) {
	event: sdl.Event
	quit := false
	app.gameState = scaffolding.GameState.UNKNOWN

	sdl.SetRenderTarget(app.window.renderer, app.board.texture)
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
	sdl.RenderClear(app.window.renderer)

	scaffolding.RenderText(app, thankYouForPlaying)

	sdl.SetRenderTarget(app.window.renderer, nil)
	sdl.RenderTexture(app.window.renderer, app.board.texture, nil, nil)
	sdl.RenderPresent(app.window.renderer)
	sdl.Delay(2000)
}

GameRun :: proc(app: ^scaffolding.App) {
	event: sdl.Event
	quit := false

	for quit == false {
		sdl.zerop(&event)
		for sdl.PollEvent(&event) == true {
			#partial switch event.type {
			case sdl.EventType.QUIT:
				app.gameState = scaffolding.GameState.UNKNOWN
				quit = true
			case sdl.EventType.KEY_DOWN:
				switch event.key.key {
				case sdl.K_ESCAPE:
					fallthrough
				case sdl.K_Q:
					quit = true
					app.gameState = scaffolding.GameState.End
				}
			}
		}
		//  Blit the board to the texture
		sdl.SetRenderTarget(app.window.renderer, app.board.texture)
		sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
		sdl.RenderClear(app.window.renderer)
		RenderBoard(app)
		RenderCells(app)
		scaffolding.RenderText(app, playerOneStart)
		//  Blit the board to the window
		sdl.SetRenderTarget(app.window.renderer, nil)
		sdl.RenderTexture(app.window.renderer, app.board.texture, nil, nil)
		sdl.RenderPresent(app.window.renderer)
	}
}

Loop :: proc(app: ^scaffolding.App) {
	for {
		switch app.gameState {
		case scaffolding.GameState.Start:
			GameStart(app)
		case scaffolding.GameState.Playing:
			GameRun(app)
		case scaffolding.GameState.End:
			GameEnd(app)
		case scaffolding.GameState.UNKNOWN:
			return
		}
	}
}

GenerateWindow :: proc(
	title: string,
	width: i32,
	height: i32,
) -> (
	^scaffolding.Window,
	bool,
) {
	success := true
	window := new(scaffolding.Window)
	window.width = width
	window.height = height
	windowTitle := strings.clone_to_cstring(title)
	defer delete(windowTitle)
	if !sdl.CreateWindowAndRenderer(
		windowTitle,
		width,
		height,
		{},
		&window.window,
		&window.renderer,
	) {
		success = false
		sdl.Log("Failed to create window: %s ", sdl.GetError())
	}
	return window, success
}
CreateXTexture :: proc(app: ^scaffolding.App) -> ^sdl.Texture {
	xTexture := CreateTexture(app, app.width / 3, app.height / 3)
	sdl.SetTextureBlendMode(xTexture, {sdl.BlendMode.BLEND})
	sdl.SetRenderTarget(app.window.renderer, xTexture)
	sdl.SetRenderDrawBlendMode(app.window.renderer, {sdl.BlendMode.BLEND})
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0x00)
	sdl.RenderClear(app.window.renderer)
	sdl.SetRenderDrawColor(app.window.renderer, 0xff, 0x00, 0x00, 0xff)
	sdl.RenderLine(app.window.renderer, 0, 0, f32(xTexture.w), f32(xTexture.h))
	sdl.RenderLine(app.window.renderer, f32(xTexture.w), 0, 0, f32(xTexture.h))
	sdl.SetRenderTarget(app.window.renderer, nil)
	return xTexture
}

CreateOTexture :: proc(app: ^scaffolding.App) -> ^sdl.Texture {
	oTexture := CreateTexture(app, app.width / 3, app.height / 3)
	sdl.SetTextureBlendMode(oTexture, {sdl.BlendMode.BLEND})
	sdl.SetRenderTarget(app.window.renderer, oTexture)
	sdl.SetRenderDrawBlendMode(app.window.renderer, {sdl.BlendMode.BLEND})
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0x00)
	sdl.RenderClear(app.window.renderer)
	sdl.SetRenderDrawColor(app.window.renderer, 0xff, 0x00, 0x00, 0xff)

	width := oTexture.w
	height := oTexture.h
	posx := width / 2
	posy := height / 2
	for i in 0 ..< width / 2 {
		for j in 0 ..< height / 2 {
			if (i * i) + (j * j) <= width / 2 * width / 2 &&
			   (i * i) + (j * j) >= (width - 5) / 2 * (width - 5) / 2 {
				sdl.RenderPoint(
					app.window.renderer,
					f32(posx + i),
					f32(posy + j),
				)
				sdl.RenderPoint(
					app.window.renderer,
					f32(posx - i),
					f32(posy - j),
				)
				sdl.RenderPoint(
					app.window.renderer,
					f32(posx - i),
					f32(posy + j),
				)
				sdl.RenderPoint(
					app.window.renderer,
					f32(posx + i),
					f32(posy - j),
				)
			}
		}
	}
	sdl.SetRenderTarget(app.window.renderer, nil)
	return oTexture
}

CreateTexture :: proc(
	app: ^scaffolding.App,
	width, height: i32,
) -> ^sdl.Texture {
	return sdl.CreateTexture(
		app.window.renderer,
		sdl.PixelFormat.RGBA8888,
		sdl.TextureAccess.TARGET,
		width,
		height,
	)
}

main :: proc() {
	//  Global Memory leak tracking
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)

	fmt.println("Running TicTacToe")
	app := new(scaffolding.App)
	app.height = 400
	app.width = 400

	fmt.println("Init SDL")
	if !sdl.Init({sdl.InitFlag.VIDEO}) {
		log.panicf("Failed to init SDL: %s", sdl.GetError())
	}
	fmt.println("Init SDL ttf")
	sdl_ttf.Init()
	fmt.println("Load Fonts")
	app.font = scaffolding.CreateFont(
		"./assets/08-true-type-fonts/lazy.ttf",
		28,
	)
	if app.font == nil {
		log.panic("Failed to init SDL Font")
	}
	fmt.println("Create Window")
	window, ok := GenerateWindow("TicTacToe", app.width, app.height)
	if !ok {
		log.panic("Failed to create window")
	}
	app.window = window

	fmt.println("Init Game")
	InitGame(app)

	fmt.println("Setup text")
	app.board.texture = CreateTexture(app, app.width, app.height)

	gameName = new(scaffolding.Text)
	gameName.text = "Tic Tac Toe"
	gameName.color = sdl.Color{0xff, 0x00, 0xff, 0xff}
	scaffolding.UpdateText(app, gameName)
	startQuestion = new(scaffolding.Text)
	startQuestion.text = "Start Game Y/N"
	startQuestion.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, startQuestion)
	playerOneStart = new(scaffolding.Text)
	playerOneStart.text = "Player O start!"
	playerOneStart.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, playerOneStart)
	playerTwoStart = new(scaffolding.Text)
	playerTwoStart.text = "Player X start!"
	playerTwoStart.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, playerTwoStart)
	thankYouForPlaying = new(scaffolding.Text)
	thankYouForPlaying.text = "Thank you for playing!"
	thankYouForPlaying.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, thankYouForPlaying)
	oTexture = CreateOTexture(app)
	if oTexture == nil {
		log.panic("Failed to create O texture")
	}
	xTexture = CreateXTexture(app)
	if xTexture == nil {
		log.panic("Failed to create X texture")
	}

	fmt.println("Loop")
	Loop(app)
	fmt.println("Deinit")
	//  Deinit
	scaffolding.DestroyTexture(gameName.texture)
	free(gameName.texture)
	free(gameName)
	scaffolding.DestroyTexture(startQuestion.texture)
	free(startQuestion.texture)
	free(startQuestion)
	scaffolding.DestroyTexture(playerOneStart.texture)
	free(playerOneStart.texture)
	free(playerOneStart)
	scaffolding.DestroyTexture(playerTwoStart.texture)
	free(playerTwoStart.texture)
	free(playerTwoStart)
	scaffolding.DestroyTexture(thankYouForPlaying.texture)
	free(thankYouForPlaying.texture)
	free(thankYouForPlaying)
	sdl_ttf.CloseFont(app.font)
	sdl.DestroyTexture(app.board.texture)
	free(app.window)
	free(app)

	//  Close out sdl
	sdl_ttf.Quit()
	sdl.Quit()

	//  Leak detection list
	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
	}

}
