package sup

import math "core:math"
import sdl "vendor:sdl3"

BlockSize: f32 : 40
Levels: int : 10
InitialPlayerPosition: int : 0

Board :: struct {
	levels: int,
	board:  []int,
}

RC :: struct {
	row:    int,
	column: int,
}

App :: struct {
	title:     cstring,
	width:     i32,
	height:    i32,
	window:    ^sdl.Window,
	renderer:  ^sdl.Renderer,
	board:     Board,
	playerPos: int,
}

RcFromPosition :: proc(position: int) -> RC {
	r1 := (-1 + int(math.sqrt(f32(1 - 4 * -2 * position)))) / 2
	r2 := (-1 - int(math.sqrt(f32(1 - 4 * -2 * position)))) / 2
	row := r1 > r2 ? r1 : r2
	col := position - ArrayLengthForRows(row)
	return RC{row = row, column = col}
}

PositionFromRc :: proc(rc: RC) -> int {
	return ArrayLengthForRows(rc.row) + rc.column
}

ArrayLengthForRows :: proc(numRows: int) -> int {
	return (numRows * (numRows + 1)) / 2
}

UpMoves :: proc(board: Board, rc: RC) -> [dynamic]RC {
	if rc.row == 0 {
		return {}
	}
	moves: [dynamic]RC
	row := rc.row - 1
	if rc.column > 0 {
		append(&moves, RC{row = row, column = rc.column - 1})
	}
	if rc.column <= row {
		append(&moves, RC{row = row, column = rc.column})
	}

	return moves
}

DownMoves :: proc(board: Board, rc: RC) -> [dynamic]RC {
	if rc.row + 1 >= board.levels {
		return {}
	}
	moves: [dynamic]RC
	append(&moves, RC{row = rc.row + 1, column = rc.column})
	append(&moves, RC{row = rc.row + 1, column = rc.column + 1})

	return moves
}
