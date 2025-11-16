package main

import "core:fmt"

main :: proc() {
	months := []string{"Jan", "feb", "Mar", "Apr", "May", "june", "jul", "Aug", "Sep", "Oct", "nov", "Dec"}

	for month, i in months {
		if i == 5 {
			fmt.printfln("% 2d. ***%s****",i+1, month)
		} else {
			fmt.printfln("% 2d. %s",i+1, month)
		}
	}
}
