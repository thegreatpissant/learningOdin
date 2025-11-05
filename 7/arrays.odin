package main

import "core:fmt"

main :: proc() {
	nums := []int{4,2,3,4,5}
	for i := 0; i < len(nums); i+= 1 {
		fmt.println(nums[i])
	}
	for n,i in nums {
		fmt.printfln("num[%d]:= %d", i, nums[i])
	}

	#reverse for n,i in nums {
		fmt.printfln("nums[%d] = %d", i, nums[i])
	}
}
