package main

import "core:fmt"
import "core:time"

main :: proc() { 
	for i in 0..<50 { 
		fmt.printf("number: %d\r",i)
		time.sleep(time.Millisecond * 16)
	}
	fmt.println()

	rounders := []string{"┌", "┬", "┐",
				   	"┤",
				   	"┘",
				   	"┴",
					"└",
					"├",
				   	//"┼",
	}
	for i in 0..<len(rounders)*5 { 
		fmt.printf("%s   \r",rounders[i%len(rounders)])
		time.sleep(time.Millisecond * 320)
	}
	fmt.println()
}
