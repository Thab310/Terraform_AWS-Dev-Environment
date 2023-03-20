#!/bin/bash

# Update apt and install dependencies
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Download Docker GPG key and verify fingerprint
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
sudo apt-key fingerprint 0EBFCD88

# Add Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update apt and install Docker
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Add Ubuntu user to Docker group
sudo usermod -aG docker ubuntu
