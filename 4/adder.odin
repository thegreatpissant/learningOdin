package adder

import "core:fmt"

main :: proc() {
	num1 := 1
	num2 := 300
	num2 += num1
	fmt.printfln("%i + %i = %i", num1, num2, (num1 + num2))
}
