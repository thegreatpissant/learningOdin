package greeter

import "core:fmt"
import "core:time"

main :: proc() {
	theTime := time.now()
	h, _, _ := time.clock_from_time(theTime)

	if h < 10 {
		fmt.println("good morning")
	} else if h < 15 {
		fmt.println("good afternoon")
	} else {
		fmt.println("Good evening")
	}
}
