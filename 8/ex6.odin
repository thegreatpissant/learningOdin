package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	buf :[100]byte

	fmt.print("enter a number: ")
	bytes_read, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprint("Failed to read from stdin:", err)
		os.exit(-1)
	}
	s := string(buf[:bytes_read-1])
	val,ok := strconv.parse_int(s)
	if !ok {
		fmt.eprintfln("Not a number: '%s'", s)
		os.exit(-1)
	}
	if val % 10 == 0 {
		fmt.printfln("Number %d is divisable by 10!", val)
	}
	else {
		fmt.printfln("Number %d is not divisable by 10", val)
	}
}
