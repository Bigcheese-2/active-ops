# XYZ Cloud Migration Task

This project is a response to the Active Tech interview exercise. It deploys a simple Node.js application to a Kubernetes cluster (AWS EKS) using Terraform for infrastructure provisioning.

## 🚀 Overview

This solution addresses the client's (XYZ) needs by:
* **Containerization (Docker):** The Node.js app is packaged into a Docker image, ensuring consistency between environments.
* **Cloud Migration (AWS):** The entire infrastructure is provisioned on AWS, a leading public cloud.
* **Orchestration (Kubernetes):** We use EKS, a managed Kubernetes service, to handle deployment, scaling, and rollouts, which will reduce downtime.
* **Infrastructure as Code (Terraform):** The entire cloud environment (VPC, EKS Cluster) is defined in Terraform, making it repeatable, version-controlled, and transparent.

### What is Running
* **AWS VPC:** A custom, isolated network.
* **AWS EKS:** A managed Kubernetes cluster.
* **EKS Node Group:** A group of 1-2 `t3.small` EC2 instances that run the application.
* **Kubernetes Deployment:** Manages running 2 "replicas" (copies) of our application for high availability.
* **Kubernetes Service (LoadBalancer):** Exposes the application to the internet via an AWS Elastic Load Balancer.

---

## 🛠️ Prerequisites

Before you begin, you must have the following tools installed:
* [Git](https://git-scm.com/downloads)
* [Node.js](https://nodejs.org/) (v18+)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Terraform](https://www.terraform.io/downloads.html) (v1.5+)
* [AWS CLI](https://aws.amazon.com/cli/) (v2)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [jq](https://jqlang.org/download/)

You will also need:
1.  An **AWS Account** with programmatic access (Access Key & Secret).
2.  A **Docker Hub Account**.

---

## 🏃‍♂️ How to Run

1.  **Clone the repository:**
    ```bash
    git clone "https://github.com/Bigcheese-2/active-ops.git"
    cd into the repo
    ```

2.  **Configure AWS Credentials:**
    ```bash
    aws configure
    # Enter your AWS Access Key ID, Secret, and default region (e.g., us-east-1)
    ```

3.  **Log in to Docker Hub:**
    ```bash
    docker login
    # Enter your Docker Hub username and password
    ```

4.  **Run the Single Launch Command:**
    This command will build the image, push it, create the cloud infrastructure, deploy the app, and run an automated test.
    ```bash
    ./run.sh
    ```
    *Note: The `terraform apply` step will take 15-20 minutes.*

---

## 🧪 Automated Test

The `./run.sh` script automatically runs an automated test (`./test.sh`) at the end of the deployment.

This test:
1.  Fetches the public URL of the AWS Load Balancer.
2.  Makes an HTTP request to the endpoint.
3.  Parses the JSON response and validates that the `message` key equals `"Automate all the things!"`.
4.  Exits with a `0` (success) or `1` (failure).

---

## 🧹 How to Clean Up

**This is critical to avoid AWS charges.**

To destroy all cloud resources created by this project (EKS cluster, VPC, etc.), run the cleanup script:
```bash
./cleanup.sh