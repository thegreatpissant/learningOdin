package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
    for a in os.args[1:] {
        n, ok := strconv.parse_int(a)

        if ok && n % 10 == 0 {
            fmt.println(n)
        }
    }
}
