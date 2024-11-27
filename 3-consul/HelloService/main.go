
package main

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net/http"
    "os"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
    // Get ResponseService address from Consul
    responseServiceAddr, err := getServiceAddress("response-service")
    if err != nil {
        http.Error(w, "Failed to get ResponseService address", http.StatusInternalServerError)
        return
    }

    // Call ResponseService
    resp, err := http.Get(fmt.Sprintf("http://%s/response", responseServiceAddr))
    if err != nil {
        http.Error(w, "Failed to contact ResponseService", http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()

    var response map[string]interface{}
    json.NewDecoder(resp.Body).Decode(&response)

    response["message"] = "Hello from HelloService!"

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func getServiceAddress(serviceName string) (string, error) {
    consulAddr := os.Getenv("CONSUL_HTTP_ADDR")
    resp, err := http.Get(fmt.Sprintf("http://%s/v1/catalog/service/%s", consulAddr, serviceName))
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    var services []struct {
        ServiceAddress string `json:"ServiceAddress"`
        ServicePort    int    `json:"ServicePort"`
    }

    json.NewDecoder(resp.Body).Decode(&services)

    if len(services) == 0 {
        return "", fmt.Errorf("No instances of service %s found", serviceName)
    }

    return fmt.Sprintf("%s:%d", services[0].ServiceAddress, services[0].ServicePort), nil
}

func main() {
    http.HandleFunc("/hello", helloHandler)
    fmt.Println("HelloService running on port 5000...")
    log.Fatal(http.ListenAndServe(":5000", nil))
}
