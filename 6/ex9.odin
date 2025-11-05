package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) != 2 {
		fmt.println("Need one numeric argument")
		os.exit(-1)
	}
	value, ok := strconv.parse_int(os.args[1])
	if !ok {
		fmt.println("Need on numeric argument, got: ", os.args[1])
		os.exit(-1)
	}
	if value >= 1 && value <= 12 {
		for i in 1..<13 {
			fmt.printfln("%d * % 2d = %d", value, i, value * i)
		}
	}
}
