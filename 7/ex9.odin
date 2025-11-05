package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	v1 : int
	v2 : int
	ok : bool

	v1, ok = strconv.parse_int(os.args[1])
	if !ok {
		fmt.println("Invalid arg: ", os.args[1])
		os.exit(-1)
	}
	v2, ok = strconv.parse_int(os.args[2])
	if !ok {
		fmt.println("Invalid arg: ", os.args[2])
		os.exit(-1)
	}
	if v1 > v2 {
		fmt.printfln("%d is greater than %d", v1, v2)
		os.exit(-1)
	}
	for i in v1..=v2 {
		fmt.println(i)
	}
}

