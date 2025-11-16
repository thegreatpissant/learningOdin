package main

import "core:fmt"
import "core:strconv"
import "core:os"

main :: proc()
{
	a := int_convert_or_fail("42")
	b := int_convert_or_fail("foo")

	fmt.println(a + b)
}

// This is in bad form
int_convert_or_fail ::proc(str:string) -> int{
	value, ok := strconv.parse_int(str)
	if !ok {
		fmt.printfln("Failed to convert %s to an int",str)
		os.exit(-1)
	}
	return value
}
