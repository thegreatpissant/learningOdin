package main

import "core:fmt"
import "core:strconv"
import "core:os"

main :: proc()
{
	if len(os.args) < 3 {
		fmt.println("Not enough args")
		os.exit(-1)
	}

	sum : int
	if os.args[1] == "even" {
		for arg in os.args[2:] {
			value, _ := strconv.parse_int(arg)
			if value % 2 == 0 {
				sum += value
			}
		}
	} else if os.args[1] == "odd" {
		for arg in os.args[2:] {
			value, _ := strconv.parse_int(arg)
			if value % 2 != 0 {
				sum += value
			}
		}
	} else {
		fmt.printfln("%s, is incorrect", os.args[1])
		os.exit(-1)
	}

	fmt.printfln("Sum of %s numbers is : %d", os.args[1], sum)
}
