package main

import "core:fmt"
import "core:os"
import "core:time"

main :: proc() {
	if len(os.args) < 2 {
		fmt.println("Enter a name")
		os.exit(-1)
	}

	greeting := ""

	h, _, _ := time.clock_from_time(time.now())
	if h < 11 {
		greeting = "morning"
	} else if h < 4 {
		greeting = "afternoon"
	} else {
		greeting = "night"
	}

	for argument in os.args[1:] {
		fmt.printfln("Good %s, %s", greeting, argument)
	}
}
