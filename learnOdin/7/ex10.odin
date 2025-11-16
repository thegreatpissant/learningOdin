package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) != 4 {
		fmt.println("Not enough args")
		os.exit(-1)
	}
	v1 : int
	v2 : int
	oddEven : bool
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
	oddEven, ok = strconv.parse_bool(os.args[3])
	if !ok {
		fmt.println("even odd")
		os.exit(-1)
	}

	if v1 > v2 {
		fmt.printfln("%d is greater than %d", v1, v2)
		os.exit(-1)
	}
	for i in v1..=v2 {
		if oddEven && i % 2 == 0 {
			fmt.println(i)
		} else  if !oddEven && i % 2 != 0 {
			fmt.println(i)
		}
	}
}

