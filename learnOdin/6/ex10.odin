package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	for arg in os.args {
		_, intOk := strconv.parse_int(arg)
		if intOk {
			fmt.printfln("%s is an integer", arg)
			continue
		}
		_, boolOk := strconv.parse_bool(arg)
		if boolOk {
			fmt.printfln("%s is a bool", arg)
			continue
		}
		fmt.printfln("%s is neither a bool or integer", arg)
	}

}
