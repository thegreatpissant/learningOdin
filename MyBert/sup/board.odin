package sup

import "core:fmt"
import sdl "vendor:sdl3"

RenderBoard :: proc(app: ^App) {
	sdl.SetRenderDrawColor(app.renderer, 0xff, 0xff, 0xff, 0x00)
	offset: f32 = 20
	//  Render all the block in the board
	for i in 0 ..< len(app.board.board) {
		rc := RcFromPosition(i)
		// fmt.printfln("pos: %d, rc: %v", i, rc)
		x := offset + BlockSize * f32(rc.column)
		y := offset + BlockSize * f32(rc.row)
		rect := sdl.FRect{x, y, BlockSize, BlockSize}
		sdl.RenderRect(app.renderer, &rect)
	}
}

RenderPlayer :: proc(app:^App) {
	rc := RcFromPosition(app.playerPos)
	offset: f32 = 20
	x := offset + BlockSize * f32(rc.column)
	y := offset + BlockSize * f32(rc.row)

	sdl.SetRenderDrawColor(app.renderer, 0x55, 0xff, 0xff, 0x00)
	sdl.RenderLine(app.renderer, x, y, x+BlockSize, y + BlockSize )
	sdl.RenderLine(app.renderer, x, y+BlockSize, x + BlockSize, y)
}