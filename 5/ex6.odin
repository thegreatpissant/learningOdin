package main

import "core:fmt"

main :: proc() {
    games := []string{"Donkey Kong", "Pacman", "Breakout", "Defender"}
    years := []int{1981, 1980, 1976, 1981}

    fmt.printfln("% 15s | % 5s", "GAME", "YEAR")
	for i in 0..<16 {
		fmt.print("-")
	}
	fmt.print("+")
	for i in 0..<6 {
		fmt.print("-")
	}
	fmt.println();
    for g, i in games {
	    fmt.printfln("%15s | % 5d", g, years[i])
    }
}
