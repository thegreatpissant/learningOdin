package nownow

import "core:fmt"
import "core:time"

main :: proc() {
	n := time.now()
	h, m, s := time.clock_from_time(n)
	fmt.println(h,":",m,":",s)
}
