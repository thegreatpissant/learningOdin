package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	buf: [100]byte

	fmt.print("Enter a number: ")
	bufLen, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintf("Failed to read stdin")
		os.exit(-1)
	}
	val, ok := strconv.parse_int(string(buf[:bufLen-1]))
	if !ok {
		fmt.println("Failed to convert ", string(buf[:bufLen -1]), " to an integer")
		os.exit(-1)
	}
	fmt.println("You entered ", val)
}
