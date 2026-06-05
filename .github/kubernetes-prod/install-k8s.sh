#!/bin/bash
set -e

# Определяем актуальную стабильную версию Kubernetes
LATEST=$(curl -s https://dl.k8s.io/release/stable.txt)          # v1.36.0
LATEST_MAJOR_MINOR=$(echo $LATEST | cut -d. -f1-2)             # v1.36
LATEST_MINOR=$(echo $LATEST_MAJOR_MINOR | cut -d. -f2)         # 36

# Желаемая версия (на единицу ниже)
DESIRED_MINOR=$((LATEST_MINOR - 1))                             # 35
DESIRED_MAJOR_MINOR="v1.${DESIRED_MINOR}"                       # v1.35

# Добавляем репозиторий именно для желаемой версии, а не для последней
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${DESIRED_MAJOR_MINOR}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${DESIRED_MAJOR_MINOR}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Устанавливаем пакеты нужной версии
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet
echo "Установлены: kubelet, kubeadm, kubectl версии:"
kubelet --version
kubeadm version
kubectl version --client