package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1024, 768, "Hellope!")
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawText("Hellope!", 10, 10, 500, rl.VIOLET)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
