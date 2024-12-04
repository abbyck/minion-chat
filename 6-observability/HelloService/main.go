package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// Define Prometheus metrics
	totalRequests = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "hello_service_total_requests",
			Help: "Total number of requests received by HelloService",
		},
	)
	successfulResponses = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "hello_service_successful_responses",
			Help: "Total number of successful responses by HelloService",
		},
	)
	failedResponses = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "hello_service_failed_responses",
			Help: "Total number of failed responses by HelloService",
		},
	)
	requestDuration = prometheus.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "hello_service_request_duration_seconds",
			Help:    "Histogram of response times for requests to HelloService",
			Buckets: prometheus.DefBuckets,
		},
	)
)

func init() {
	// Register metrics with Prometheus
	prometheus.MustRegister(totalRequests)
	prometheus.MustRegister(successfulResponses)
	prometheus.MustRegister(failedResponses)
	prometheus.MustRegister(requestDuration)
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	// total requests counter
	totalRequests.Inc()

	// request duration
	timer := prometheus.NewTimer(requestDuration)
	defer timer.ObserveDuration()

	responseServiceAddr, err := getServiceAddress("response-service")
	if err != nil {
		failedResponses.Inc() // failed responses counter
		http.Error(w, "Failed to get ResponseService address", http.StatusInternalServerError)
		return
	}

	// Call ResponseService
	resp, err := http.Get(fmt.Sprintf("http://%s/response", responseServiceAddr))
	if err != nil {
		failedResponses.Inc()
		http.Error(w, "Failed to contact ResponseService", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	var response map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		failedResponses.Inc()
		http.Error(w, "Failed to decode ResponseService response", http.StatusInternalServerError)
		return
	}

	response["message"] = "Hello from HelloService!"
	successfulResponses.Inc() // Increment successful responses counter

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

	if err := json.NewDecoder(resp.Body).Decode(&services); err != nil {
		return "", err
	}

	if len(services) == 0 {
		return "", fmt.Errorf("no instances of service %s found", serviceName)
	}

	return fmt.Sprintf("%s:%d", services[0].ServiceAddress, services[0].ServicePort), nil
}

func main() {
	// Register Prometheus metrics endpoint
	http.Handle("/metrics", promhttp.Handler())

	http.HandleFunc("/hello", helloHandler)

	fmt.Println("HelloService running on port 5000...")
	log.Fatal(http.ListenAndServe(":5000", nil))
}
