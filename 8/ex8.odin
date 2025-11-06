package main

import "core:fmt"
import "core:os"
import "core:strconv"

getNumber :: proc(num:int) -> int {
	buf:[255]byte

	for {
		fmt.printf("Enter number #%d: ", num)
		bytes_read, err := os.read(os.stdin, buf[:])
		if err != nil {
			fmt.eprintf("failed to read from stdin: ", err)
			os.exit(-1)
		}
		s := string(buf[:bytes_read-1])
		val, ok := strconv.parse_int(s)
		if ok {
			return val
		}
		fmt.eprintfln("'%s' is not a number", s)
	}
}

main :: proc () {

	fmt.println("Find the min and max of 10 of your numbers")
	min := getNumber(1)
	max := min
	for i in 2..=10 {
		num := getNumber(i)
		if num < min {
			min = num
		}
		if num > max {
			max = num
		}
	}
	fmt.printfln("min was %d, max was %d", min, max)
}
