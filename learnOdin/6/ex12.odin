package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
    sum_of_evens := 0
    for a in os.args[1:] {
        n, ok := strconv.parse_int(a)
        if ok && n > 0 && n % 2 == 0 {
            sum_of_evens += n
        } else {
			fmt.printfln("%s is not a valid integer", a)
		}
    }

    fmt.printfln("The sum of all even numbers is: %d", sum_of_evens)
}
