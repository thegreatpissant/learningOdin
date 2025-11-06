package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	buf: [512]byte

	fmt.print("Enter something: ")
	bytes_read, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintln("Unable to read from stdin:", err)
		os.exit(-1)
	}

	s := string(buf[:bytes_read-1])
	lc := strings.to_lower(s)
	fmt.printfln("You wrote: '%s'", lc)
}
