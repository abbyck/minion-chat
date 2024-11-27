
# Part 2: Packer Integration

In this part, we use **HashiCorp Packer** to build reusable Amazon Machine Images (AMIs) for the Minion Chat demo. Packer simplifies the deployment process by pre-installing necessary dependencies like Docker, Consul, and Nomad.

---

## Steps for Packer Integration

### 1. Install Packer

Install Packer on your system.

**For macOS**:
```bash
brew install packer
```

**For Ubuntu**:
```bash
apt-get install packer
```

Verify the installation:
```bash
packer --version
```

---

### 2. Packer Template

Below are sample Packer templates for different parts of the demo.

#### **`packer.json` (For Part 1: Docker-only Image)**
```json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "source_ami": "ami-0c02fb55956c7d316",
      "instance_type": "t2.micro",
      "ssh_username": "ubuntu",
      "ami_name": "minion-chat-docker-only-{{timestamp}}",
      "ami_description": "AMI with Docker pre-installed for Minion Chat demo"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update -y",
        "sudo apt-get install -y docker.io",
        "sudo systemctl enable docker"
      ]
    }
  ]
}
```

---

#### **`packer.json` (For Part 3: Docker + Consul)**
```json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "source_ami": "ami-0c02fb55956c7d316",
      "instance_type": "t2.micro",
      "ssh_username": "ubuntu",
      "ami_name": "minion-chat-docker-consul-{{timestamp}}",
      "ami_description": "AMI with Docker and Consul pre-installed for Minion Chat demo"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update -y",
        "sudo apt-get install -y docker.io unzip",
        "sudo systemctl enable docker",
        "curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip",
        "unzip consul_1.14.4_linux_amd64.zip",
        "sudo mv consul /usr/local/bin/",
        "sudo mkdir -p /etc/consul.d",
        "echo '{"server": true, "datacenter": "dc1", "data_dir": "/tmp/consul", "ui": true}' | sudo tee /etc/consul.d/config.json"
      ]
    }
  ]
}
```

---

#### **`packer.json` (For Part 4: Docker + Consul + Nomad)**
```json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "source_ami": "ami-0c02fb55956c7d316",
      "instance_type": "t2.micro",
      "ssh_username": "ubuntu",
      "ami_name": "minion-chat-docker-consul-nomad-{{timestamp}}",
      "ami_description": "AMI with Docker, Consul, and Nomad pre-installed for Minion Chat demo"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update -y",
        "sudo apt-get install -y docker.io unzip curl",
        "sudo systemctl enable docker",
        "curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip",
        "unzip consul_1.14.4_linux_amd64.zip",
        "sudo mv consul /usr/local/bin/",
        "curl -O https://releases.hashicorp.com/nomad/1.5.6/nomad_1.5.6_linux_amd64.zip",
        "unzip nomad_1.5.6_linux_amd64.zip",
        "sudo mv nomad /usr/local/bin/",
        "sudo mkdir -p /etc/consul.d /etc/nomad.d",
        "echo '{"server": true, "datacenter": "dc1", "data_dir": "/tmp/consul", "ui": true}' | sudo tee /etc/consul.d/config.json",
        "echo '{"datacenter": "dc1", "data_dir": "/tmp/nomad", "server": {"enabled": true, "bootstrap_expect": 1}}' | sudo tee /etc/nomad.d/config.json"
      ]
    }
  ]
}
```

#### **`packer.json` (For Part 5: Docker + Consul + Nomad + Vault)**
```json
{{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "source_ami": "ami-0c02fb55956c7d316",
      "instance_type": "t2.micro",
      "ssh_username": "ubuntu",
      "ami_name": "minion-chat-docker-consul-nomad-vault-{{timestamp}}",
      "ami_description": "AMI with Docker, Consul, Nomad, and Vault pre-installed for Minion Chat demo"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo apt-get update -y",
        "sudo apt-get install -y docker.io unzip curl",
        "sudo systemctl enable docker",

        # Install Consul
        "curl -O https://releases.hashicorp.com/consul/1.14.4/consul_1.14.4_linux_amd64.zip",
        "unzip consul_1.14.4_linux_amd64.zip",
        "sudo mv consul /usr/local/bin/",
        "sudo mkdir -p /etc/consul.d",
        "echo '{\"server\": true, \"datacenter\": \"dc1\", \"data_dir\": \"/tmp/consul\", \"ui\": true}' | sudo tee /etc/consul.d/config.json",

        # Install Nomad
        "curl -O https://releases.hashicorp.com/nomad/1.5.6/nomad_1.5.6_linux_amd64.zip",
        "unzip nomad_1.5.6_linux_amd64.zip",
        "sudo mv nomad /usr/local/bin/",
        "sudo mkdir -p /etc/nomad.d",
        "echo '{\"datacenter\": \"dc1\", \"data_dir\": \"/tmp/nomad\", \"server\": {\"enabled\": true, \"bootstrap_expect\": 1}}' | sudo tee /etc/nomad.d/config.json",

        # Install Vault
        "curl -O https://releases.hashicorp.com/vault/1.14.1/vault_1.14.1_linux_amd64.zip",
        "unzip vault_1.14.1_linux_amd64.zip",
        "sudo mv vault /usr/local/bin/",
        "sudo mkdir -p /etc/vault.d",
        "echo '{\"storage\": {\"consul\": {\"address\": \"127.0.0.1:8500\", \"path\": \"vault/\"}}, \"listener\": [{\"tcp\": {\"address\": \"0.0.0.0:8200\", \"tls_disable\": true}}]}' | sudo tee /etc/vault.d/config.json",

        # Enable and start services
        "sudo systemctl enable docker",
        "sudo systemctl start docker"
      ]
    }
  ]
}
```


---

### 3. Build the AMI

Run the following command to build the AMI:
```bash
packer build packer.json
```

---

### 4. Update Terraform to Use Packer AMI

Once the AMI is built, update the `ami_id` in `variables.tf` or directly reference the Packer output.

**Example**:
```hcl
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-xxxxx" # Replace with the Packer AMI ID
}
```

---

## Benefits of Adding Packer Integration

1. **Simplified Terraform Configuration**:
   - No need for complex `user_data` scripts.

2. **Consistency**:
   - Ensures all instances start with the same baseline setup.

3. **Reusability**:
   - Use the same AMI for all parts of the demo.

4. **Faster Deployment**:
   - Pre-installed dependencies reduce setup time.

---

## Where to Add

- **Before Part 1**: Start with a Docker-only Packer image for a clean baseline.
- **Before Part 3**: Extend the image to include Consul.
- **Before Part 4**: Add Nomad to the same image.
- **Before Part 5**: Add Vault to the same image.

---
