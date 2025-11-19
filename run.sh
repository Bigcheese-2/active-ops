#!/bin/bash
set -e # Exit immediately if a command fails


DOCKER_USER="yemishabi"

echo "--- 1. Building and Pushing Docker Image ---"
docker build -t $DOCKER_USER/active-ops:v1.
docker push $DOCKER_USER/active-ops:v1

echo "--- 2. Provisioning AWS EKS Cluster (This takes ~20 mins) ---"
cd terraform
terraform init
terraform apply -auto-approve

echo "--- 3. Configuring kubectl ---"
# Get the config command from terraform output and run it
CONFIG_CMD=$(terraform output -raw configure_kubectl)
$CONFIG_CMD
cd ..

echo "--- 4. Deploying Application to Kubernetes ---"
# Wait for nodes to be ready before deploying
echo "Waiting for cluster nodes to be ready..."
sleep 60 
kubectl apply -f k8s/

echo "--- 5. Waiting for deployment to be ready... ---"
kubectl rollout status deployment/active-ops-deployment

echo "--- 6. Running Automated Tests ---"
# Make the test script executable
chmod +x ./test.sh
./test.sh

echo "🎉 --- Deployment Complete! --- 🎉"