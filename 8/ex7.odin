package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	buf:[255]byte

	fmt.print("Enter a number: ")
	bytes_read, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintfln("Failed to read stdin: %s", err)
		os.exit(-1)
	}
	s := string(buf[:bytes_read-1])
	val, ok := strconv.parse_int(s)
	if !ok {
		fmt.eprintf("'%s' is not a number", s)
		os.exit(-1)
	}
	if val % 2 != 0 {
		fmt.printfln("%d is an odd number", val)
	} else {
		fmt.printfln("%d is your number", val)
	}
}
