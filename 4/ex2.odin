package main

import "core:fmt"

main :: proc() {

	is_hungry := false
	if is_hungry {
		fmt.println("What would you like to eat?")
	} else {
		fmt.println("Would you like a drink?")
	}
}
