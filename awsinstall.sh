#!/bin/bash

echo "Installing Awscli"
sudo snap install awscli 

echo "--------entering in Jenkins container ------------------"

docker exec -it jenkins bash

apt update

apt upgrade -y 

apt install -y awscli 


logout 
