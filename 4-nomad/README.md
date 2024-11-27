
# Part 4: Nomad Integration

## Overview
This part uses Nomad to orchestrate the deployment and management of HelloService and ResponseService, integrated with Consul.

## Steps to Run

1. **Navigate to the Part 3 directory**:
   ```bash
   cd Part3-Nomad
   ```

2. **Start Consul and Nomad**:
   ```bash
   docker-compose -f docker-compose.nomad.yml up
   ```

3. **Deploy the Services Using Nomad**:
   - Deploy **ResponseService**:
     ```bash
     nomad job run nomad-jobs/response-service.nomad
     ```
   - Deploy **HelloService**:
     ```bash
     nomad job run nomad-jobs/hello-service.nomad
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

5. **Access UIs**:
   - **Nomad UI**:
     ```plaintext
     http://localhost:4646
     ```
   - **Consul UI**:
     ```plaintext
     http://localhost:8500
     ```

## Key Points
- Nomad simplifies service deployment and scaling.
- Nomad integrates with Consul for service discovery and secure communication.
