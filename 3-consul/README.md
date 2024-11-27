
# Part 3: Consul Integration

## Overview
This part introduces Consul for service discovery, key-value (KV) storage, and mutual TLS between HelloService and ResponseService.

## Steps to Run

1. **Navigate to the Part 2 directory**:
   ```bash
   cd Part2-ConsulIntegration
   ```

2. **Start Consul and Services**:
   ```bash
   docker-compose up --build
   ```

3. **Populate the Consul KV Store**:
   Add Minion phrases to the KV store:
   ```bash
   curl --request PUT --data '["Bello!", "Poopaye!", "Tulaliloo ti amo!"]' http://localhost:8500/v1/kv/minion_phrases
   ```

4. **Test the Services**:
   - Test **HelloService**:
     ```bash
     curl http://localhost:5000/hello
     ```
   - Expected Response:
     ```json
     {
       "message": "Hello from HelloService!",
       "minion_phrases": ["Bello!", "Poopaye!", "Tulaliloo ti amo!"],
       "response_service": "Bello from ResponseService!"
     }
     ```

5. **Access Consul UI**:
   - Open the Consul UI in a browser:
     ```plaintext
     http://localhost:8500
     ```

## Key Points
- Dynamic service discovery: HelloService resolves ResponseService using Consul.
- Centralized configuration via KV store.
- Mutual TLS: Consul Connect secures inter-service communication.
