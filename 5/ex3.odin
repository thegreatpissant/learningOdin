package main

import "core:fmt"
import "core:os"

main :: proc() {
	if len(os.args) != 3 {
		fmt.println("This program requires exactly 2 arguments")
		fmt.println("Got ", len(os.args))
		os.exit(-1)
	}
	fmt.println("The arguments are: ", os.args[1:])
}
