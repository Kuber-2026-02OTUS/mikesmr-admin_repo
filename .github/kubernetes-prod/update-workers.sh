cat > update-workers.sh << 'EOF'
#!/bin/bash
set -e

# Список IP ваших worker-нод (известные вам)
WORKER_IPS=(
  46.21.246.64
  158.160.45.118
  158.160.61.115
)

# Функция получения имени узла по его внутреннему IP (10.0.0.x)
get_node_name_by_ip() {
    local ip=$1
    kubectl get nodes -o wide --no-headers | awk -v ip="$ip" '$6 == ip {print $1}'
}

# Функция обновления одного worker
update_worker() {
    local ip=$1
    echo "=== Обработка worker $ip ==="

    # Получаем имя узла через kubectl по внутреннему IP
    # Сначала получаем внутренний IP worker (через SSH)
    local internal_ip=$(ssh ubuntu@$ip "ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'")
    echo "Внутренний IP: $internal_ip"

    local node_name=$(get_node_name_by_ip "$internal_ip")
    if [ -z "$node_name" ]; then
        echo "Не удалось найти имя узла для IP $internal_ip. Пропускаем."
        return 1
    fi
    echo "Имя узла в кластере: $node_name"

    # Drain узел
    echo "Draining $node_name ..."
    kubectl drain $node_name --ignore-daemonsets --delete-emptydir-data

    # Обновление на worker
    echo "Обновление компонентов на $ip ..."
    ssh ubuntu@$ip bash -s << 'ENDSSH'
        set -e
        # Переключение репозитория на v1.36
        sudo rm -f /etc/apt/sources.list.d/kubernetes.list
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
        echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

        # Снять hold и обновить
        sudo apt-mark unhold kubeadm kubelet kubectl
        sudo apt-get update
        sudo apt-get install -y kubeadm kubelet kubectl
        sudo apt-mark hold kubeadm kubelet kubectl

        # Выполнить kubeadm upgrade node
        sudo kubeadm upgrade node

        sudo systemctl restart kubelet
        echo "Worker $HOSTNAME обновлён"
ENDSSH

    # Вернуть узел в планирование
    echo "Uncordoning $node_name ..."
    kubectl uncordon $node_name

    echo "=== Worker $ip обновлён и активирован ==="
    echo ""
}

# Основной цикл
for ip in "${WORKER_IPS[@]}"; do
    update_worker $ip
    # Небольшая пауза между узлами
    sleep 5
done

echo "✅ Все worker-ноды обновлены до версии 1.36"
EOF

chmod +x update-workers.sh