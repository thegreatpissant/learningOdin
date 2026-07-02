package mybert

import "base:runtime"
import "core:fmt"
import sup "sup"
import sdl "vendor:sdl3"

AppInit :: proc "c" (
	appState: ^rawptr,
	argc: i32,
	argv: [^]cstring,
) -> sdl.AppResult {
	context = runtime.default_context()
	fmt.printfln("AppInit")
	fmt.printfln("Initialize SDL")
	if !sdl.Init({.VIDEO, .AUDIO}) {
		fmt.printfln("Failed to initialize SDL %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	fmt.printfln("Initialize SDL - DONE")

	fmt.printfln("Initialize App")
	app := new(sup.App)
	appState^ = app
	app.title = "rbert"
	app.width = 1280
	app.height = 720
	app.window = new(sdl.Window)
	app.renderer = new(sdl.Renderer)
	fmt.printfln("Initialize App - DONE")

	fmt.printfln("Initialize Window")
	if !sdl.CreateWindowAndRenderer(
		app.title,
		app.width,
		app.height,
		{},
		&app.window,
		&app.renderer,
	) {
		fmt.printfln("Failed to create wnidow and renderer %s", sdl.GetError())
		return sdl.AppResult.FAILURE
	}
	sdl.SetRenderLogicalPresentation(
		app.renderer,
		app.width,
		app.height,
		sdl.RendererLogicalPresentation.STRETCH,
	)
	fmt.printfln("Initialize Window - DONE")

	fmt.printfln("Initialzie Game")
	app.board.levels = sup.Levels
	app.board.board = make([]int, sup.ArrayLengthForRows(app.board.levels))
	fmt.printfln("Board length: %d", len(app.board.board))
	for i in 0 ..= 5 {
		fmt.printfln(
			"Array Length given %d is %d",
			i,
			sup.ArrayLengthForRows(i),
		)
	}
	for i in 0 ..= 5 {
		rc := sup.RcFromPosition(i)
		pos := sup.PositionFromRc(rc)
		fmt.printfln(
			"Pos: %d, Row: %d, Col: %d, CalcPos: %d, %v",
			i,
			rc.row,
			rc.column,
			pos,
			pos == i,
		)
		fmt.printfln("UpMoves: %v: ", sup.UpMoves(app.board, rc))
		fmt.printfln("DownMoves: %v: ", sup.DownMoves(app.board, rc))
	}
	app.playerPos = sup.InitialPlayerPosition
	fmt.printfln("Initialzie Game - DONE")

	fmt.printfln("AppInit - DONE")

	return sdl.AppResult.CONTINUE
}

AppIterate :: proc "c" (app: rawptr) -> sdl.AppResult {
	app := (^sup.App)(app)
	context = runtime.default_context()
	sdl.SetRenderTarget(app.renderer, nil)
	sdl.SetRenderDrawColor(app.renderer, 0x00, 0x00, 0x00, sdl.ALPHA_OPAQUE)
	sdl.RenderClear(app.renderer)
	sup.RenderBoard(app)
	sup.RenderPlayer(app)
	sdl.RenderPresent(app.renderer)
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
		case sdl.Scancode.Q:
			fmt.printfln("Move up and to the left")
			playerRc := sup.RcFromPosition(app.playerPos)
			fmt.printfln("Player: i:%v, rc:%v", app.playerPos, playerRc)
			upMoves := sup.UpMoves(
				app.board,
				sup.RcFromPosition(app.playerPos),
			)
			fmt.printfln("UpMoves: %v", upMoves[:])
			if len(upMoves) == 0 {
				return sdl.AppResult.CONTINUE
			}
			//  move up to the left if possible
			for i in 0 ..< len(upMoves) {
				if upMoves[i].column == playerRc.column - 1{
					app.playerPos = sup.PositionFromRc(upMoves[i])
					break
				}
			}
			fmt.printfln("Player: %v", app.playerPos)

		case sdl.Scancode.E:
			fmt.printfln("Move up and to the right.")
			playerRc := sup.RcFromPosition(app.playerPos)
			fmt.printfln("Player: i:%v, rc:%v", app.playerPos, playerRc)
			upMoves := sup.UpMoves(app.board, playerRc)
			fmt.printfln("UpMoves: %v", upMoves[:])
			if len(upMoves) == 0 {
				return sdl.AppResult.CONTINUE
			}
			for i in 0 ..< len(upMoves) {
				if upMoves[i].column == playerRc.column {
					app.playerPos = sup.PositionFromRc(upMoves[i])
					break
				}
			}
			fmt.printfln("Player: %v", app.playerPos)

		case sdl.Scancode.D:
			fmt.printfln("Move down and to the right")
			playerRc := sup.RcFromPosition(app.playerPos)
			fmt.printfln("Player: i: %v, rc: %v", app.playerPos, playerRc)
			downMoves := sup.DownMoves(app.board, playerRc)
			fmt.printfln("Downmoves: %v", downMoves[:])
			if len(downMoves) == 0 {
				return sdl.AppResult.CONTINUE
			}
			for i in 0..<len(downMoves) {
				if downMoves[i].column == playerRc.column + 1 {
					app.playerPos = sup.PositionFromRc(downMoves[i])
				}
			}
			fmt.printfln("Player: %v", app.playerPos)
		case sdl.Scancode.A:
			fmt.printfln("Move down and to the left")
			playerRc:= sup.RcFromPosition(app.playerPos)
			fmt.printfln("Player: i: %v, rc: %v", app.playerPos, playerRc)
			downMoves := sup.DownMoves(app.board, playerRc)
			fmt.printfln("Downmoves: %v", downMoves[:])
			if len(downMoves) == 0 {
				return sdl.AppResult.CONTINUE
			}
			for i in 0..<len(downMoves) {
				if downMoves[i].column == playerRc.column {
					app.playerPos = sup.PositionFromRc(downMoves[i])
					fmt.printfln("Found move %v", downMoves[i])
				}
			}
			fmt.printfln("Player: i: %v", app.playerPos)
		}

	}
	return sdl.AppResult.CONTINUE
}

AppQuit :: proc "c" (app: rawptr, result: sdl.AppResult) {
	app := (^sup.App)(app)
	context = runtime.default_context()
	delete(app.board.board)
	free(app)
	sdl.Quit()
}
main :: proc() {
	renderer := new(sdl.Renderer)
	renderer = nil
	argv: cstring = ""
	returnCode := sdl.EnterAppMainCallbacks(
		0,
		&argv,
		AppInit,
		AppIterate,
		AppEvent,
		AppQuit,
	)
	fmt.printfln("App returned : %v", returnCode)
}
