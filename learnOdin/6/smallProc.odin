package main

import "core:fmt"

main :: proc() {
	a := value()
	b := doubler(value())
	c := doubler(2)
	// c := doubler()

	fmt.printfln("The values are %d, %d, and %d", a, b, c)
}

value :: proc() -> int {
	return 47
}

doubler :: proc(value:int) -> int {
	return value * 2
}
