# Kubeadm Setup

## On all nodes

#### Update and install packages

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

#### Setup kernel module

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

lsmod | grep br_netfilter
lsmod | grep overlay
```

#### Setup kernel params

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

#### Install container runtime (containerd instead of docker)

```bash
sudo apt-get install -y containerd
```

#### Setup the Cgroups, since we are using systemd as init process

```bash
sudo mkdir -p /etc/containerd
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd
```

#### Download the key (v1.29)

```bash
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

#### Add into apt repository

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

#### Get kubernetes packages

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

#### Setup autocomplete

```bash
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
exec bash
```

#### Make sure swap is off, else kubeadm init might fail

```bash
sudo swapoff -a
```

#### Listen to VM network not hte NAT one

```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip ${INTERNAL_IP}'
EOF
```

## Only on master node

#### Init the kubeadm

```bash
POD_CIDR=10.244.0.0/16
SERVICE_CIDR=10.96.0.0/16
sudo kubeadm init --pod-network-cidr $POD_CIDR --service-cidr $SERVICE_CIDR --apiserver-advertise-address $INTERNAL_IP
```

#### After init

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### To reset kubeadm if anyhting wrong

```bash
sudo kubeadm reset
rm -rf ~/.kube
```

#### Get the weave (network plugin) as yaml

```bash
curl -L https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml > weave.yaml
```

#### Add below into the yaml where the weave container located

```yaml
- name: IPALLOC_RANGE
  value: 10.244.0.0/16
```

#### Deploy the network plugin

```bash
kubectl apply -f weave.yaml
```

#### For joining nodes (different each time kubeadm init)

```bash
sudo kubeadm join 192.168.56.11:6443 --token 97eufk.shsns3vv4ognbbcc \
 --discovery-token-ca-cert-hash sha256:e3c18c2a1be7224e476b4168f14ae68f4865260d5ee3d308b3a2a0e492b46bba
```
