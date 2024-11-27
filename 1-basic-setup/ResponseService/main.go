
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
)

func responseHandler(w http.ResponseWriter, r *http.Request) {
    response := map[string]string{"message": "Bello from ResponseService!"}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func main() {
    http.HandleFunc("/response", responseHandler)
    fmt.Println("ResponseService running on port 5001...")
    log.Fatal(http.ListenAndServe(":5001", nil))
}
