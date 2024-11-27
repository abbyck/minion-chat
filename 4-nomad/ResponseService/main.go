
package main

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
)

func responseHandler(w http.ResponseWriter, r *http.Request) {
    // Fetch Minion phrases from Consul KV
    phrases, err := getMinionPhrases()
    if err != nil {
        http.Error(w, "Failed to fetch Minion phrases", http.StatusInternalServerError)
        return
    }

    // Respond with Minion phrases and message
    response := map[string]interface{}{
        "message":        "Bello from ResponseService!",
        "minion_phrases": phrases,
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func getMinionPhrases() ([]string, error) {
    consulAddr := os.Getenv("CONSUL_HTTP_ADDR")
    resp, err := http.Get(fmt.Sprintf("http://%s/v1/kv/minion_phrases?raw", consulAddr))
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    var phrases []string
    body, _ := ioutil.ReadAll(resp.Body)
    json.Unmarshal(body, &phrases)

    return phrases, nil
}

func main() {
    http.HandleFunc("/response", responseHandler)
    fmt.Println("ResponseService running on port 5001...")
    log.Fatal(http.ListenAndServe(":5001", nil))
}
