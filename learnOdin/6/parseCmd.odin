package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	sum : int
	for arg in os.args[1:] {
		value, ok := strconv.parse_int(arg)
		if !ok {
			fmt.println("Failed to parse value: ", arg)
			os.exit(-1)
		}
		fmt.println("Got value: ", value)
		sum += value
	}

	fmt.println("sum: ", sum)
}
