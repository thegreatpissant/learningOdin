package main

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc () { 
	for i in 0..=100 {
		outStr := ""
		if i % 3 == 0 {
			outStr = "fizz "
		} else if i % 5 == 0 {
			outStr = strings.concatenate({outStr, "buzz"})
		} else {
			buff : []byte
			cStr := strconv.itoa(buff[:],i)
			outStr = strings.concatenate({outStr, cStr})
		}
		fmt.println(outStr)
	}
}
