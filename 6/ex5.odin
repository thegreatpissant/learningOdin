package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	sum : int

	for arg in os.args[1:] {
		value, _ := strconv.parse_int(arg)
		sum += value
	}
	fmt.println("Num of values: ", len(os.args[1:]), " avg: ", f32(sum) / f32(len(os.args[1:])))
}
