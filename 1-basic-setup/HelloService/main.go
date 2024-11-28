package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	resp, err := http.Get("http://localhost:5001/response") // Static URL
	if err != nil {
		http.Error(w, "Failed to contact ResponseService", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var response map[string]string
	json.NewDecoder(resp.Body).Decode(&response)

	response["hello"] = "Hello from HelloService!"
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/hello", helloHandler)
	fmt.Println("HelloService running on port 5000...")
	log.Fatal(http.ListenAndServe(":5000", nil))
}
