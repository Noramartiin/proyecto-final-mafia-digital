#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker

sudo docker run -dp 80:5000 hjalmarb/final_project:latest
