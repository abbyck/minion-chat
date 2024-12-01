
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

## Key Points
- Dynamic service discovery: HelloService resolves ResponseService using Consul.
- Centralized configuration via KV store.
- Mutual TLS: Consul Connect secures inter-service communication.
