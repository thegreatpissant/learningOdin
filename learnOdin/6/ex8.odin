package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	if len(os.args) < 3 {
		fmt.println("Not enough args, need a bool value followed by values")
	}
	evenOdd, ok := strconv.parse_bool(os.args[1])
	if ok && evenOdd == true {
		for arg in os.args[2:] {
			value, vok := strconv.parse_int(arg)
			if vok && value >= 50 {
				fmt.printfln("%d >= 50", value)
			}
		}
	} else if ok && evenOdd == false {
		for arg in os.args[2:] {
			value, vok := strconv.parse_int(arg)
			if vok && value < 50 {
				fmt.printfln("%d < 50", value)
			}
		}
	} else {
		fmt.println("Bool value required, got: ", os.args[1])
		os.exit(-1)
	}

}
