# Nginx Ingress Controller Setup

## Pre-requisites

- Download helm

## Install the controller

```bash
# Add the repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install
helm install nginx-ingress ingress-nginx/ingress-nginx
```

## Port forward the local traffic to the nginx ingress controller

```bash
# Set kubectl to able to open lower port (<1024)
sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/kubectl

kubectl port-forward service/nginx-ingress-ingress-nginx-controller 443 --address 0.0.0.0
```

## Set the hosts file to point to cc4-hello.com

```txt
127.0.0.1       localhost
192.168.56.11   cc4-hello.com
```
