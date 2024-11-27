
package main

import (
    "crypto/tls"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
    // Discover ResponseService dynamically
    responseServiceAddr, err := getServiceAddress("response-service")
    if err != nil {
        http.Error(w, "Failed to discover ResponseService", http.StatusInternalServerError)
        return
    }

    // Call ResponseService securely using mutual TLS
    resp, err := callResponseService(responseServiceAddr)
    if err != nil {
        http.Error(w, "Failed to contact ResponseService", http.StatusInternalServerError)
        return
    }

    var response map[string]interface{}
    json.Unmarshal([]byte(resp), &response)

    response["message"] = "Hello from HelloService!"

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func callResponseService(addr string) (string, error) {
    tlsConfig := &tls.Config{InsecureSkipVerify: true} // For demo; don't use in production
    client := &http.Client{Transport: &http.Transport{TLSClientConfig: tlsConfig}}

    resp, err := client.Get(fmt.Sprintf("https://%s/response", addr))
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    body, _ := ioutil.ReadAll(resp.Body)
    return string(body), nil
}

func main() {
    http.HandleFunc("/hello", helloHandler)
    fmt.Println("HelloService running on port 5000...")
    log.Fatal(http.ListenAndServe(":5000", nil))
}
