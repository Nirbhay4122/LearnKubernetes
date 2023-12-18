##Install k8s cluster using kubeadm
#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

set -euxo pipefail

# Variable Declaration

KUBERNETES_VERSION="1.28.1-00"
VERSION="1.28"
# You can check the all available go version in Link: https://go.dev/dl/
GO_VERSION="1.20.12"

# disable swap
sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg git

# Install docker
curl -fsSL https://get.docker.com | sudo bash

# Install cri-dockered
cd /opt/ && sudo git clone https://github.com/Mirantis/cri-dockerd.git
cd /opt/cri-dockerd/

# install kubelet, kubectl, kubeadm
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# Generate sourcelist file
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# Installing kubelet, kubeadm, kubectl
sudo apt-get update
sudo apt-get install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"
sudo apt-mark hold kubelet kubeadm kubectl

# Installing go lang
sudo wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -P /opt/
sudo tar -C /usr/local -xzf /opt/go${GO_VERSION}.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile
