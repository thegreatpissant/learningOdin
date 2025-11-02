package app

import "core:fmt"
import "core:os"

main :: proc() {
	if len(os.args) < 2 {
		fmt.println("You did not pass in any arguments")
		os.exit(-1)
	}
	for a in os.args[1:] {
		fmt.println(a)
	}
}
