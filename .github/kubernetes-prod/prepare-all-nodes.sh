#!/bin/bash
set -e

MASTER_IP="158.160.53.110"
WORKER1_IP="46.21.246.64"
WORKER2_IP="158.160.45.118"
WORKER3_IP="158.160.61.115"

NODES="$MASTER_IP $WORKER1_IP $WORKER2_IP $WORKER3_IP"

for IP in $NODES; do
  echo "=== Подготовка узла $IP ==="
  ssh ubuntu@$IP bash -s << 'EOF'
    # Отключение swap
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab

    # Загрузка модулей ядра
    sudo modprobe overlay
    sudo modprobe br_netfilter

    # Настройка sysctl
    cat <<EOT | sudo tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOT
    sudo sysctl --system

    # Установка containerd
    sudo apt-get update
    sudo apt-get install -y containerd
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    echo "Подготовка узла $IP завершена"
EOF
done

echo "✅ Все узлы подготовлены."