#!/bin/bash
sudo apt-get update
sudo apt-get install default-jre
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get install -y python3.7
sudo apt-get install -y python3.7-venv