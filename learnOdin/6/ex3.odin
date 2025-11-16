package main

import "core:fmt"
import "core:strconv"
import "core:os"

main :: proc() {
	for arg in os.args[1:] {
		value, ok := strconv.parse_int(arg)
		if ok && value % 3 == 0 && value % 5 == 0 {
			fmt.printfln("%d is divisiable by 3 or 5", value)
		} else {
			fmt.printfln("%s is not divisable by 3 or 5", arg)
		}
	}
}
