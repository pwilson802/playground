package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Starting server on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("Error starting server:", err)
	}
}

type Numbers struct {
	First  int
	Second int
}

func (n *Numbers) Sum() int {
	return n.First + n.Second
}

func (n *Numbers) Multiply() int {
	return n.First * n.Second
}
