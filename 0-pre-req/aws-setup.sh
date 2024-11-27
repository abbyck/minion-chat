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