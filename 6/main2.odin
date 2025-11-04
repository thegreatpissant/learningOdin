package main

import "core:fmt"
import "core:strconv"
import "core:os"

main :: proc() {
	sa := "12"
	sb := "foo"

	number1 : int
	number2 : int
	ok : bool

	number1, ok = strconv.parse_int(sa)
	if !ok {
		fmt.println("Not a number: ", sa)
		os.exit(1)
	}
	number2, ok = strconv.parse_int(sb)
	if !ok {
		fmt.println("Not a number: ", sb)
		os.exit(-1)
	}

	fmt.println(number1 + number2)
}
