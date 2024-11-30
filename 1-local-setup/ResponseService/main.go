package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

func responseHandler(w http.ResponseWriter, r *http.Request) {
	message := "Bello from ResponseService!"
	// Check if the environment variable INSTANCE_ID is set
	if instanceID := os.Getenv("INSTANCE_ID"); instanceID != "" {
		message = fmt.Sprintf("Bello from ResponseService %s!", instanceID)
	}

	response := map[string]string{"response_message": message}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/response", responseHandler)
	fmt.Println("ResponseService running on port 5001...")
	log.Fatal(http.ListenAndServe(":5001", nil))
}
