#!/bin/bash
echo "--- 🧹 Destroying all cloud infrastructure ---"
cd terraform
terraform destroy -auto-approve
cd ..
echo "--- Cleanup Complete ---"