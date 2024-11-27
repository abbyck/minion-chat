
# Steps to Run Part 1 (Basic Setup)

## Overview
In **Part 1**, we deploy two simple microservices, HelloService and ResponseService, to demonstrate basic inter-service communication. HelloService acts as the primary entry point, handling requests to its /hello endpoint. It fetches a response from ResponseService at its /response endpoint and combines the messages into a single JSON output. HelloService returns a friendly message "Hello from HelloService!" alongside the "Bello from ResponseService!" response received from ResponseService. The two services communicate using static IPs and ports, showcasing the foundational setup for microservices without involving advanced tools like Consul for service discovery or Nomad for orchestration.

---

## Prerequisites
1. **Tools Installed**:
   - Docker (For local setup)
   - Terraform (For AWS deployment)
   - AWS CLI (For AWS deployment)
2. **AWS Setup** (For AWS deployment):
   - An AWS account with access keys configured.
   - A key pair created in your AWS region for SSH access to EC2 instances.

---

## Running Locally

### **Prerequisites**
Ensure Docker is installed and running on your machine.

### **Step-by-Step Guide**

#### 1. **Navigate to the Project Directory**
Navigate to the directory containing the `main.go` files for HelloService and ResponseService.

```bash
cd Part1-BasicSetup
```

#### 2. **Build Docker Images**
Build Docker images for HelloService and ResponseService.

1. **Build HelloService**:
   ```bash
   cd HelloService
   docker build -t helloservice:local .
   ```

2. **Build ResponseService**:
   ```bash
   cd ../ResponseService
   docker build -t responseservice:local .
   ```

#### 3. **Run Docker Containers**
Run the Docker containers for both services.

1. **Run ResponseService**:
   ```bash
   docker run -d -p 5001:5001 --name responseservice responseservice:local
   ```

2. **Run HelloService**:
   ```bash
   docker run -d -p 5000:5000 --name helloservice --link responseservice:responseservice helloservice:local
   ```

#### 4. **Test the Services**

1. **Test HelloService**:
   Open a terminal and run:
   ```bash
   curl http://localhost:5000/hello
   ```
   Expected Output:
   ```json
   {
       "message": "Hello from HelloService!",
       "response_message": "Bello from ResponseService!"
   }
   ```

2. **Test ResponseService**:
   Open a terminal and run:
   ```bash
   curl http://localhost:5001/response
   ```
   Expected Output:
   ```json
   {
       "message": "Bello from ResponseService!"
   }
   ```

#### 5. **Verify and Debug**
- Check the running Docker containers:
  ```bash
  docker ps
  ```
- View container logs:
  ```bash
  docker logs <container-id>
  ```

#### 6. **Stop and Cleanup**
To stop and remove the running containers:
```bash
docker stop helloservice responseservice
docker rm helloservice responseservice
```

To remove the built images:
```bash
docker rmi helloservice:local responseservice:local
```

---

## Running on AWS

### **Step-by-Step Guide**

### 1. **Clone the Repo or Set Up Files**
Ensure you have the required Terraform files and Go files for HelloService and ResponseService. If you already have a zip file, extract it.

### 2. **Navigate to Part 1 Directory**
```bash
cd Part1-BasicSetup
```

---

### 3. **Prepare Terraform Files**

#### **Edit `variables.tf`**
Update the following variables:
1. **AWS Region**:
   - Ensure the region matches where you want to deploy resources.
2. **AMI ID**:
   - Use a valid Ubuntu AMI for your region.
   - Example for `us-east-1`: `ami-0c02fb55956c7d316`.
3. **Key Name**:
   - Provide the name of your existing AWS key pair (e.g., `my-key-pair`).

---

### 4. **Initialize Terraform**
Run the following command to download required providers:
```bash
terraform init
```

---

### 5. **Deploy HelloService and ResponseService**
Use Terraform to apply the infrastructure configuration:
```bash
terraform apply
```

Review the changes and type `yes` to confirm.

---

### 6. **Access the Services**
Once deployment is complete, Terraform will output the public IP addresses for both services:

Example Output:
```plaintext
hello_service_url = "http://<hello-service-public-ip>:5000/hello"
response_service_url = "http://<response-service-public-ip>:5001/response"
```

Test the services using `curl`:
1. **Test HelloService**:
   ```bash
   curl http://<hello-service-public-ip>:5000/hello
   ```
   Expected Output:
   ```json
   {
       "message": "Hello from HelloService!",
       "response_message": "Bello from ResponseService!"
   }
   ```

2. **Test ResponseService**:
   ```bash
   curl http://<response-service-public-ip>:5001/response
   ```
   Expected Output:
   ```json
   {
       "message": "Bello from ResponseService!"
   }
   ```

---

### 7. **Verify and Debug**
- **Logs**:
  SSH into the instances using your key pair to view logs:
  ```bash
  ssh -i <path-to-key.pem> ubuntu@<hello-service-public-ip>
  ```
  Check the logs:
  ```bash
  sudo docker logs <container-id>
  ```

- **Connectivity**:
  Ensure HelloService can reach ResponseService via the specified static IP.

---

### 8. **Cleanup**
To remove the infrastructure, use Terraform:
```bash
terraform destroy
```
Confirm by typing `yes`.

---

## Additional Notes
- If you modify the Go files, rebuild the Docker images and push them to Docker Hub.
- Use a consistent naming scheme for your services (e.g., `helloservice:latest` and `responseservice:latest`).

---

## Why This Setup?

  • Simple Learning:
  • Demonstrates inter-service communication without introducing complex tools or concepts.
  • Foundation:
  • Sets up the base infrastructure to expand upon in future parts, where dynamic service discovery and orchestration will be introduced.

## Limitations

  1.  Static IPs and Ports:
  • The hardcoded configuration makes scaling and dynamic updates difficult.
  • It’s not suitable for production environments where services may move between nodes or instances.
  2.  No Load Balancing:
  • Requests to ResponseService always go to a single, predefined address.
  3.  No Security:
  • No authentication, encryption, or secure communication is configured between the services.

## Next Steps

In subsequent parts, we address these limitations by:

  • Introducing Packer: To create reusable AMIs with pre-installed dependencies, simplifying deployment and ensuring consistency.
  • Adding Consul: For dynamic service discovery, allowing services to locate and communicate with each other without hardcoding static IPs (Part 2).
  • Integrating Nomad: For orchestration and scaling, enabling efficient deployment and management of services across multiple nodes (Part 3).
  • Utilizing Vault: For secure secret management, dynamically generating and securely distributing secrets like database credentials (Part 4).

This incremental approach demonstrates how to evolve a simple microservice setup into a robust, production-ready system.