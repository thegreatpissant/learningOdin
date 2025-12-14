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

// Text
gameName: ^scaffolding.Text
startQuestion: ^scaffolding.Text
playerX: ^scaffolding.Text
playerO: ^scaffolding.Text
pressAnyKeyToPlay: ^scaffolding.Text
thankYouForPlaying: ^scaffolding.Text
playerXWins: ^scaffolding.Text
playerOWins: ^scaffolding.Text
noPlayerWins: ^scaffolding.Text
oTexture: ^sdl.Texture
xTexture: ^sdl.Texture

InitGame :: proc(app: ^scaffolding.App) {
	app.gameState = scaffolding.GameState.Start
	InitBoard(app)
	app.currentPlayer = scaffolding.Cell.PLAYER_X
	app.winner = scaffolding.Cell.NONE
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
	dstRect := sdl.FRect{posx, posy, width, height}
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
				case sdl.K_ESCAPE:
					app.gameState = scaffolding.GameState.UNKNOWN
					quit = true
				case:
					app.gameState = scaffolding.GameState.Playing
					quit = true
				}
			case sdl.EventType.MOUSE_BUTTON_DOWN:
				app.gameState = scaffolding.GameState.Playing
				quit = true
			}
		}
		sdl.SetRenderTarget(app.window.renderer, app.board.texture)
		sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
		sdl.RenderClear(app.window.renderer)

		scaffolding.RenderText(
			app,
			gameName,
			&scaffolding.Position {
				f32(app.width / 2 - gameName.texture.width / 2),
				f32(app.height / 3 - gameName.texture.height),
			},
		)
		scaffolding.RenderText(app, pressAnyKeyToPlay)
		//  Or Change to Y/N as buttons for mouse support.

		sdl.SetRenderTarget(app.window.renderer, nil)
		sdl.RenderTexture(app.window.renderer, app.board.texture, nil, nil)
		sdl.RenderPresent(app.window.renderer)
	}
}

GameEnd :: proc(app: ^scaffolding.App) {
	app.gameState = scaffolding.GameState.UNKNOWN

	sdl.SetRenderTarget(app.window.renderer, app.board.texture)
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
	sdl.RenderClear(app.window.renderer)

	if app.winner == scaffolding.Cell.PLAYER_X { 
		scaffolding.RenderText(app, playerXWins,
			&scaffolding.Position {
				f32(app.width / 2 - gameName.texture.width / 2),
				f32(app.height / 3 - gameName.texture.height),
			}
			)
	} else if app.winner == scaffolding.Cell.PLAYER_O { 
		scaffolding.RenderText(app, playerOWins,
			&scaffolding.Position {
				f32(app.width / 2 - gameName.texture.width / 2),
				f32(app.height / 3 - gameName.texture.height),
			}
			)
	} else if app.winner == scaffolding.Cell.STALEMATE { 
		scaffolding.RenderText(app, noPlayerWins,
			&scaffolding.Position {
				f32(app.width / 2 - gameName.texture.width / 2),
				f32(app.height / 3 - gameName.texture.height),
			})
	}
	scaffolding.RenderText(app, thankYouForPlaying)

	sdl.SetRenderTarget(app.window.renderer, nil)
	sdl.RenderTexture(app.window.renderer, app.board.texture, nil, nil)
	sdl.RenderPresent(app.window.renderer)
	sdl.Delay(2000)
}

CheckWinner :: proc(app: ^scaffolding.App) -> bool { 
	// 3 in a row
	for i in 0..<3 { 
		if app.board.board[i][0] == app.board.board[i][1] && 
			app.board.board[i][0] == app.board.board[i][2] { 
			app.winner =  app.board.board[i][0]
			break
		}
	}
	// 3 in a col
	for j in 0..<3 { 
		if app.board.board[0][j] == app.board.board[1][j] && 
			app.board.board[0][j] == app.board.board[2][j] { 
			app.winner =  app.board.board[0][j]
			break
		}
	}
	// \ diag
	if app.board.board[0][0] == app.board.board[1][1] && 
		app.board.board[0][0] == app.board.board[2][2] { 
		app.winner = app.board.board[0][0]
	}
	// / diag
	if app.board.board[2][0] == app.board.board[1][1] && 
		app.board.board[2][0] == app.board.board[0][2] { 
		app.winner =  app.board.board[2][0]
	}
	if app.winner != scaffolding.Cell.NONE { 
		return true
	}
	//  Moves left?
	for i in app.board.board { 
		for j in i { 
			if j == scaffolding.Cell.NONE { 
				return false
			}
		}
	}
	// No moves left, stalemate
	app.winner = scaffolding.Cell.STALEMATE
	return true
}
GameRun :: proc(app: ^scaffolding.App) {
	event: sdl.Event
	quit := false
	buttonPosition := scaffolding.Position{}
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
			case sdl.EventType.MOUSE_BUTTON_DOWN:
				_ = sdl.GetMouseState(&buttonPosition.x, &buttonPosition.y)
				//  Calculate the cell position
				x := i32(buttonPosition.x) / (app.width / 3)
				y := i32(buttonPosition.y) / (app.height / 3)
				//  Can Player make a move?
				if app.board.board[x][y] == scaffolding.Cell.NONE {
					app.board.board[x][y] = app.currentPlayer
					//  Check for a win
					if CheckWinner(app) { 
						quit = true
						app.gameState = scaffolding.GameState.End
					}
					//  Switch to the other player
					if app.currentPlayer == scaffolding.Cell.PLAYER_X {
						app.currentPlayer = scaffolding.Cell.PLAYER_O
					} else {
						app.currentPlayer = scaffolding.Cell.PLAYER_X
					}
				}
			}
		}
		//  Blit the board to the texture
		sdl.SetRenderTarget(app.window.renderer, app.board.texture)
		sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0xff)
		sdl.RenderClear(app.window.renderer)
		RenderBoard(app)
		RenderCells(app)
		#partial switch app.currentPlayer {
		case scaffolding.Cell.PLAYER_X:
			scaffolding.RenderText(app, playerX)
		case scaffolding.Cell.PLAYER_O:
			scaffolding.RenderText(app, playerO)
		}
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
	texture := CreateTexture(app, app.width / 3, app.height / 3)
	sdl.SetTextureBlendMode(texture, {sdl.BlendMode.BLEND})
	sdl.SetRenderTarget(app.window.renderer, texture)
	sdl.SetRenderDrawBlendMode(app.window.renderer, {sdl.BlendMode.BLEND})
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0x00)
	sdl.RenderClear(app.window.renderer)
	sdl.SetRenderDrawColor(app.window.renderer, 0xff, 0x00, 0x00, 0xff)
	sdl.RenderLine(app.window.renderer, 0, 0, f32(texture.w), f32(texture.h))
	sdl.RenderLine(app.window.renderer, f32(texture.w), 0, 0, f32(texture.h))
	sdl.SetRenderTarget(app.window.renderer, nil)
	return texture
}

CreateOTexture :: proc(app: ^scaffolding.App) -> ^sdl.Texture {
	texture := CreateTexture(app, app.width / 3, app.height / 3)
	sdl.SetTextureBlendMode(texture, {sdl.BlendMode.BLEND})
	sdl.SetRenderTarget(app.window.renderer, texture)
	sdl.SetRenderDrawBlendMode(app.window.renderer, {sdl.BlendMode.BLEND})
	sdl.SetRenderDrawColor(app.window.renderer, 0x00, 0x00, 0x00, 0x00)
	sdl.RenderClear(app.window.renderer)
	sdl.SetRenderDrawColor(app.window.renderer, 0xff, 0x00, 0x00, 0xff)

	width := texture.w
	height := texture.h
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
		return texture
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
	playerX = new(scaffolding.Text)
	playerX.text = "Player X"
	playerX.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, playerX)
	playerO = new(scaffolding.Text)
	playerO.text = "Player O"
	playerO.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, playerO)
	thankYouForPlaying = new(scaffolding.Text)
	thankYouForPlaying.text = "Thank you for playing!"
	thankYouForPlaying.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, thankYouForPlaying)
	pressAnyKeyToPlay = new(scaffolding.Text)
	pressAnyKeyToPlay.text = "Press any key to play"
	pressAnyKeyToPlay.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, pressAnyKeyToPlay)
	playerXWins = new(scaffolding.Text)
	playerXWins.text = "Player X Wins!"
	playerXWins.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, playerXWins)
	playerOWins = new(scaffolding.Text)
	playerOWins.text = "Player O Wins!"
	playerOWins.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, playerOWins)
	noPlayerWins = new(scaffolding.Text)
	noPlayerWins.text = "Stalemate"
	noPlayerWins.color = sdl.Color{0xff, 0x00, 0x00, 0xff}
	scaffolding.UpdateText(app, noPlayerWins)
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
	scaffolding.DestroyTexture(playerX.texture)
	free(playerX.texture)
	free(playerX)
	scaffolding.DestroyTexture(playerO.texture)
	free(playerO.texture)
	free(playerO)
	scaffolding.DestroyTexture(pressAnyKeyToPlay.texture)
	free(pressAnyKeyToPlay.texture)
	free(pressAnyKeyToPlay)
	scaffolding.DestroyTexture(thankYouForPlaying.texture)
	free(thankYouForPlaying.texture)
	free(thankYouForPlaying)
	scaffolding.DestroyTexture(playerOWins.texture)
	free(playerOWins.texture)
	free(playerOWins)
	scaffolding.DestroyTexture(playerXWins.texture)
	free(playerXWins.texture)
	free(playerXWins)
	scaffolding.DestroyTexture(noPlayerWins.texture)
	free(noPlayerWins.texture)
	free(noPlayerWins)
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
