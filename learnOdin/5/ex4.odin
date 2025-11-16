package main

import "core:fmt"
import "core:os"

main :: proc() {
	for arg, index in os.args {
		if index % 2 == 0 {
			fmt.println(arg)
		}
	}
}
