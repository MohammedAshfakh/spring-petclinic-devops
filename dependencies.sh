#!/bin/bash

sudo apt update && sudo apt upgrade -y
echo "-----------------completed apt update and upgrade--------------"
sudo apt install git -y

echo "------------installing eksctl ------------------"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version



echo "----installing kubectl---"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo snap install awscli kubectl --classic -y 
