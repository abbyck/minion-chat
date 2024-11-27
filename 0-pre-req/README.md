
# AWS Setup Prerequisites

## Overview
This document provides instructions on setting up AWS CLI and creating an EC2 key pair required for deploying services to AWS. Use the provided script to automate this process.

---

## Prerequisites
1. **Install AWS CLI**:
   - Ensure the AWS CLI is installed on your system.
   - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2. **IAM Permissions**:
   - Your AWS account must have permissions to:
     - Configure access keys.
     - Create EC2 key pairs.

3. **Bash Terminal**:
   - A terminal with Bash support to execute the setup script.

---

## Step-by-Step Guide

### 1. **Download and Run the Script**
1. Save the following script as `aws_setup.sh`:

```bash
#!/bin/bash

# Exit on any error
set -e

echo "Starting AWS setup..."

# 1. Check if AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo "Error: AWS CLI is not installed. Install it from https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" >&2
  exit 1
fi

# 2. Configure AWS CLI
echo "Configuring AWS CLI..."
read -p "Enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -sp "Enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo
read -p "Enter your default AWS region (e.g., us-east-1): " AWS_DEFAULT_REGION

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_DEFAULT_REGION"
aws configure set output json

echo "AWS CLI configured successfully!"

# 3. Create a key pair
echo "Creating an EC2 key pair..."
read -p "Enter a name for the key pair (e.g., my-key-pair): " KEY_PAIR_NAME

if aws ec2 create-key-pair --key-name "$KEY_PAIR_NAME" --query 'KeyMaterial' --output text > "${KEY_PAIR_NAME}.pem"; then
  chmod 400 "${KEY_PAIR_NAME}.pem"
  echo "Key pair '$KEY_PAIR_NAME' created and saved as '${KEY_PAIR_NAME}.pem'."
else
  echo "Error creating key pair. The name may already exist or you may lack permissions."
  exit 1
fi

echo "AWS setup completed successfully!"
echo "Next steps:"
echo "1. Use the key pair '${KEY_PAIR_NAME}.pem' to access your EC2 instances."
echo "2. Ensure your default region is set to '$AWS_DEFAULT_REGION'."
```

2. Make the script executable:
   ```bash
   chmod +x aws_setup.sh
   ```

3. Run the script:
   ```bash
   ./aws_setup.sh
   ```

---

### 2. **What the Script Does**
1. Configures AWS CLI with your credentials and region.
2. Creates an EC2 key pair and saves the private key (`.pem`) file in your current directory.

---

## Outputs
1. AWS CLI will be configured with your credentials and region.
2. A private key file (e.g., `my-key-pair.pem`) will be saved locally. Use this key to SSH into EC2 instances.

---

## Notes
- Keep the private key file secure and do not expose it publicly.
- Ensure that your IAM permissions allow you to create key pairs and configure AWS CLI.

---
