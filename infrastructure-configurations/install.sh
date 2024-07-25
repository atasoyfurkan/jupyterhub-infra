#!/bin/bash


# Install k3s
sudo apt update
curl -sfL https://get.k3s.io | sh -

# Install Docker
## Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
## Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Check if KUBECONFIG export line already exists in .bashrc
if ! grep -q 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' ~/.bashrc; then
    # Append the export command to .bashrc
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
    echo 'KUBECONFIG export added to .bashrc'
    sudo chown $(id -u):$(id -g) /etc/rancher/k3s/k3s.yaml
else
    echo 'KUBECONFIG export already exists in .bashrc'
fi

#### Kubernetes Installation ####

# Install helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash


# Change ingress controller to nginx
## Disable Traefik on K3S
curl -sfL https://get.k3s.io | sh -s - --disable traefik

## Install nginx ingress controller using helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

# apply cert-manager and cluster issuer
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.0/cert-manager.yaml
kubectl apply -f common/cluster-issuer-letsencrypt.yaml

# create shared volume
kubectl apply -f common/jupyterhub-shared-volume-pvc.yaml

# Install jupyterhub
## pre-pull singleuser image to avoid timeouts during applying helm chart
sudo docker pull quay.io/jupyter/datascience-notebook:latest
## apply helm chart
helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update
helm upgrade --cleanup-on-fail \
  --install jupyterhub jupyterhub/jupyterhub \
  --namespace default \
  --create-namespace \
  --version=3.2.1 \
  --values hub/config.yaml
## create api_token secret
### !!!Important please go to /hub admin page and create a new api token and replace the value in the secret then activate the next line
### kubectl apply -f hub/secret.yaml


# Install frontend
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/ingress.yaml

# Install backend
## install postgresql
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install backend-db bitnami/postgresql \
    --namespace default \
    --version 14.0.4 \
    --set auth.enablePostgresUser=false \
    --set auth.username=postgres \
    --set auth.password=postgres \
    --set auth.database=postgres \
    --atomic --wait --timeout 600s --history-max 3

## install other backend components
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/ingress.yaml

