package main

import "core:fmt"
import "core:strconv"
import "core:os"

main :: proc() {
	min : int
	max : int

	count := 0
	for arg in os.args[1:] {

		value, ok := strconv.parse_int(arg)
		if !ok {
			fmt.println("Not a valid number: ", arg)
			continue
		}
		if count == 0 {
			count += 1
			min = value
			max = value
			continue
		}
		if value < min {
			min = value;
		} else if value > max {
			max = value
		}
	}
	fmt.println("min: ", min)
	fmt.println("max: ", max)
}
