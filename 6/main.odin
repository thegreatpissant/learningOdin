package main

import "core:fmt"
import "core:strconv"
import "core:os"

main :: proc() {
	sa := "12"
	sb := "foo"

	a, ok := strconv.parse_int(sa)
	if !ok {
		fmt.println("not a valid integer: ", sa)
		os.exit(-1)
	}
	b, okb := strconv.parse_int(sb)
	if !okb {
		fmt.println("Not a valid integer: ", sb)
		os.exit(-1)
	}

	fmt.println(a + b)
}
