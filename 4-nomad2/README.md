
# Part 3: Consul Integration

## Overview
This part introduces Consul for service discovery, and fault tollerance for HelloService and ResponseService.

## Prerequisites
1. **Tools Installed**:
   - Terraform CLI
   - jq cli `brew install jq`
   - Packer cli
2. **Packer generated AMI** (Pre-baked AMI with Consul Server, Consul Client, Docker Images, DNS Configuration):
   - An AWS account with access keys configured.
3. **Docker Images**
   - Docker images compiled in last activity and available on docker-hub

## Steps to Run

1. **Navigate to the Part 2 directory**:
   ```bash
   cd 3-consul2
   ```

2. **Building AMI using Packer**
   ```bash
   packer init -var-file=variables.hcl image.pkr.hcl
   packer build -var-file=variables.hcl image.pkr.hcl
   ```

   Record the AMI id, we will need it in next step

3. **Deloyment**
   
   **Update variables.hcl acordingly. Sepecially the `ami`**
   ```hcl
   # Packer variables (all are required)
   region                    = "us-east-1"
   dockerhub_id              = "srahul3"

   # Terraform variables (all are required)
   ami                       = "ami-03c83c7b2955a1b4b"

   name_prefix               = "minion"
   response_service_count    = 2
   ```
   
   **Run following command**
   ```bash
   terraform init
   terraform apply -var-file=variables.hcl
   ```

4. **Test the Services**:
   - Test **HelloService**:
     ```bash
     curl http://localhost:5000/hello | jq
     ```
   - Expected Response:
     ```json
     {
      "message": "Hello from HelloService!",
      "minion_phrases": [
         "Bello!",
         "Poopaye!",
         "Tulaliloo ti amo!"
      ],
      "response_message": "Bello from ResponseService i-05506b6e36d25223a!"
     }
     ```

5. **Access Consul UI**:
   - Open the Consul UI in a browser:
     ```plaintext
     http://localhost:8500
     ```
6. **SSH to the 1st Response Service**:
   - use ssh command suggested in terraform output and connect to the instance suggested by `Hello Service response`
   - Testing DNS:
     ```bash
     curl consul.service.consul:8500
     <a href="/ui/">Moved Permanently</a>.

     curl hello-service.service.consul:5000/hello | jq
     {
      "message": "Hello from HelloService!",
      "minion_phrases": [
         "Bello!",
         "Poopaye!",
         "Tulaliloo ti amo!",
         "jello"
      ],
      "response_message": "Bello from ResponseService i-05506b6e36d25223a!"
      }

      sudo docker pause response-service

      # The other response instance shall kick in now
      curl hello-service.service.consul:5000/hello | jq
      {
      "message": "Hello from HelloService!",
      "minion_phrases": [
         "Bello!",
         "Poopaye!",
         "Tulaliloo ti amo!",
         "jello"
      ],
      "response_message": "Bello from ResponseService i-0a5e388ad2762ec84!"
      }

      sudo docker unpause response-service

      # back to the first response service
      curl hello-service.service.consul:5000/hello | jq
      {
      "message": "Hello from HelloService!",
      "minion_phrases": [
         "Bello!",
         "Poopaye!",
         "Tulaliloo ti amo!",
         "jello"
      ],
      "response_message": "Bello from ResponseService i-05506b6e36d25223a!"
      }
     ```
7. **DIY**:
   - Read the code and identify how to add `Tank yu` to the `minion_phrases`

## Key Points
- Dynamic service discovery: HelloService resolves ResponseService using Consul.
- Centralized configuration via KV store.
- Fault tollerant via consul circuit breaker
