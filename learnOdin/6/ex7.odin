package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	for arg in os.args[1:] {
		value, ok := strconv.parse_int(arg)
		if ok && value % 10 == 0 {
			fmt.printfln("%d is divisiable by 10", value)
		}
	}
}
