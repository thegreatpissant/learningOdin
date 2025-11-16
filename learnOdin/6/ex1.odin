package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	sum : int

	for arg in os.args[1:] {
		value, _ := strconv.parse_int(arg)
		if value % 2 == 0 {
			sum += value
		}
	}
	fmt.println("Sum of even args is: ", sum)
}
