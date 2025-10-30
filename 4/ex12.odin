package main

import "core:fmt"
import "core:time"

main :: proc() {
	h, m, s := time.clock_from_time(time.now())
	ampm := "am"
	if h > 12 {
		ampm = "pm"
		h -= 12
	}
	fmt.printfln("%i:%i:%i %s", h, m, s, ampm)
}
