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
	// Prometheus metrics
	totalRequests = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "response_service_total_requests",
			Help: "Total number of requests received",
		},
	)
	successfulResponses = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "response_service_successful_responses",
			Help: "Total number of successful responses",
		},
	)
	failedResponses = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "response_service_failed_responses",
			Help: "Total number of failed responses",
		},
	)
	requestDuration = prometheus.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "response_service_request_duration_seconds",
			Help:    "Histogram of response times for requests",
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

func responseHandler(w http.ResponseWriter, r *http.Request) {
	totalRequests.Inc() // total requests counter

	// Measure request duration
	timer := prometheus.NewTimer(requestDuration)
	defer timer.ObserveDuration()

	// Fetch Minion phrases from Consul KV
	phrases, err := getMinionPhrases()
	if err != nil {
		failedResponses.Inc() // Increment failed responses counter
		http.Error(w, "Failed to fetch Minion phrases", http.StatusInternalServerError)
		return
	}

	// Respond with Minion phrases and message
	response := map[string]interface{}{
		"message":        "Bello from ResponseService!",
		"minion_phrases": phrases,
	}

	successfulResponses.Inc() // Increment successful responses counter
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
	if err := json.NewDecoder(resp.Body).Decode(&phrases); err != nil {
		return nil, err
	}

	return phrases, nil
}

func main() {
	http.HandleFunc("/response", responseHandler)
	http.Handle("/metrics", promhttp.Handler()) // Prometheus metrics endpoint

	fmt.Println("ResponseService running on port 5001...")
	log.Fatal(http.ListenAndServe(":5001", nil))
}
