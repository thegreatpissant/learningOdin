package fizz

import "core:fmt"

main :: proc() {
	num := 15

	if num > 15 {
		fmt.println("Print too large")
	} else if num == 3 {
		fmt.println("fizz")
	} else if num == 5 {
		fmt.println("buzz")
	} else if num == 15 {
		fmt.println("fizz buzz")
	} else if num < 1 {
		fmt.println("number too low")
	}
}
