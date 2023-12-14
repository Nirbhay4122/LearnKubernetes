# Kubernetes Cluster setup using Kubeadm (AWS EC2)
### Prerequisite to install on Ubuntu/Debian Based Linux
* RAM: 2GB (Minimum)
* STORAGE: 20GB (8GB Minimum)
* 6443 Port should be available.
* Internet Connection Should be available.
* t2.medium instance type or higher (On AWS)
---
## Run On Mater & Worker Both Nodes
### STEP-1 Install the basic dependencies on both server master & worker nodes.
```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
### STEP-2 Download the public signing key for the Kubernetes package repositories.
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
### STEP-3 Add the appropriate Kubernetes apt repository.
```bash
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
### STEP-4 Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
> **Note:**
> Please note that this repository has packages only for _Kubernetes 1.28_; for other Kubernetes minor versions, you need to change the Kubernetes minor version in the URL to match your desired minor version.
```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
> After completing the installation successfully, verify the version ```kubectl version``` & ```kubeadm version```.
---
## Run On Mater Node
### 1. Initialize the Kubernetes master node.
```bash
sudo kubeadm init
```
### 2. Set up local kubeconfig (both for the root user and normal user):
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 3. Apply Weave network to make master node ready:
```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# To check the node's availability.
kubectl get node
```
### 4. Generate a token for worker nodes to join with the master node:
```bash
sudo kubeadm token create --print-join-command
```
> **Note:**
> This command will generate the token with the complete command, Just copy the command and save it for later to join the worker node with the cluster.
---
## Run On Worker Node
### 1. Run the following commands on the worker node.
> Note:
> To confirm whether the cluster is not initialized on both(master & worker) nodes.
```bash
sudo kubeadm reset pre-flight checks
```
### 2. To join the worker node within the cluster Run the _Join Command_, you have saved before from the master node.
> **Note:**
> To verify the cluster on the master node run ```kubectl get node``` and you will see the two nodes one is the master node (Control Panel) and the other one is the worker node.
---
**Congrats**
You have completed the Kubernetes installation using _kuberadm_ on aws EC2 Instance.



