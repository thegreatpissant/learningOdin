package main

import "core:fmt"
import "core:os"

main :: proc() {
	buf: [100]byte
	fmt.print("Enter day of the week: ")
	bufLen, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintf("Failed to read stdin")
		os.exit(-1)
	}
	day := string(buf[:bufLen-1])
	if day == "monday" {
		fmt.println("Garfield hates mondays")
	}
	else if day == "tuesday" || day == "wednesday" || day == "thursday" || day == "friday" {
		fmt.println("Any other day")
	}
	else if day == "saturday" || day == "sunday" {
		fmt.println("Its the weekend!!")
	}
	else {
		fmt.println("Not a day")
	}
}
