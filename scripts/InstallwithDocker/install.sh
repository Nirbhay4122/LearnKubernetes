##Install k8s cluster using kubeadm
#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)
#*****************Help******************
# To intialliaze the cluster (This cluster calico network)
# sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --v=5
# Install calico network interface driver
# curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml -O
# kubectl apply -f calico.yaml
##########JOIN COMMAND##################
# kubeadm token create --print-join-command
# Sample and add this in the last of the command (--cri-socket=unix:///var/run/cri-dockerd.sock --v=5)
# sudo kubeadm join 172.31.43.74:6443 --token zhafut.84u016lql2jxmyz5 --discovery-token-ca-cert-hash sha256:e627dd5d7c15246bae08ff6c00a580b94d6a1b9390401d90a45f12e5ad34dc9a

set -euxo pipefail

# Variable Declaration

KUBERNETES_VERSION="1.28.0-00"
VERSION="1.28"
CRI_DOCKERD_VERSION="0.3.8"
# You can check the all available go version in Link: https://go.dev/dl/
GO_VERSION="1.20.12"

INSTALL_K8S() {
    # disable swap
    sudo swapoff -a
    # keeps the swaf off during reboot
    if ! crontab -l | grep -E "/sbin/swapoff" >/dev/null; then
        (crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
    fi
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg git

    # Install docker, containerd.io
    if ! command -v docker >/dev/null; then
        curl -fsSL https://get.docker.com | sudo bash
    fi

    # Installing go lang
    # sudo wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -P /opt/
    # sudo tar -C /usr/local -xzf /opt/go${GO_VERSION}.linux-amd64.tar.gz
    # echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
    # source ~/.profile

    # Install cri-dockered
    if ! command -v cri-dockerd >/dev/null; then
        cd /opt/
        sudo wget https://github.com/Mirantis/cri-dockerd/releases/download/v${CRI_DOCKERD_VERSION}/cri-dockerd-${CRI_DOCKERD_VERSION}.amd64.tgz
        sudo tar -xzvf cri-dockerd-${CRI_DOCKERD_VERSION}.amd64.tgz
        cd /opt/cri-dockerd/ && sudo mv cri-dockerd /usr/local/bin/ && cd
        sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
        sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
        sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
        sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
        sudo systemctl daemon-reload
        sudo systemctl enable cri-docker.service
        sudo systemctl enable --now cri-docker.socket
    fi
    # install kubelet, kubectl, kubeadm
    # curl -fsSL https://pkgs.k8s.io/core:/stable:/v${VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    # Generate sourcelist file
    # echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    # Installing kubelet, kubeadm, kubectl
    sudo apt-get update
    sudo apt-get install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"
    sudo apt-mark hold kubelet kubeadm kubectl
}

INIT_CLUSTER() {
    # To intialliaze the cluster (This cluster calico network)
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --v=5
    mkdir -p "$HOME"/.kube
    sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
    sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
    # Install calico network interface driver
    curl https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml -O
    kubectl apply -f calico.yaml
}
INSTALL_K8S
# INIT_CLUSTER