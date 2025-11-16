package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) != 3 {
		fmt.println("Need to number arguments")
	}
	value1: int
	value2: int
	ok : bool

	value1, ok = strconv.parse_int(os.args[1])
	if !ok {
		fmt.printfln("%s is not a valid number", os.args[1])
		os.exit(-1)
	}
	value2, ok = strconv.parse_int(os.args[2])
	if !ok {
		fmt.printfln("%s is not a valid number", os.args[2])
		os.exit(-1)
	}
	fmt.printfln("3 * %d + 5 * %d - 14 = %d", value1, value2, (3 * value1 + 5 * value2 - 14))
}
