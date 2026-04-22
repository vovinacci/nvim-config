package main

import "fmt"

func main() {
	unused := "hello"
	fmt.Println("world")
	_ = unused
}
