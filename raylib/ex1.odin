package main

import "core:os"
import "core:strings"
import rl "vendor:raylib"

main :: proc() {
	name := "Hollope!"
	if len(os.args) == 2 {
		name = os.args[1]
	}
	cname := strings.clone_to_cstring(name)

	rl.InitWindow(1024, 768, "Helloper")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawText(cname, 10, 10, 250, rl.VIOLET)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
