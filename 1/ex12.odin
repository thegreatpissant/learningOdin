package main

import "core:fmt"

main :: proc() {
	price := 151

	if price > 150 {
		fmt.println("It's too expensive")
	}
	else {
		fmt.println("I'll take it!")
	}
}
