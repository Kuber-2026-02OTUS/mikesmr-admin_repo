#!/bin/bash
set -e

FOLDER_ID="b1gp0pnhs1rr4vvul155"
SUBNET_ID="e9blbl1kpejjfq3amjos"
ZONE="ru-central1-a"

# Получаем ID последнего образа Ubuntu 22.04 LTS по семейству
IMAGE_ID=$(yc compute image get-latest-from-family ubuntu-2204-lts --folder-id standard-images --format json | jq -r '.id')

SSH_PUBKEY=$(cat ~/.ssh/id_rsa.pub)

echo "Используется образ: $IMAGE_ID"

# Создание master
echo "Создание master-ноды k8s-master..."
yc compute instance create \
  --name k8s-master \
  --folder-id $FOLDER_ID \
  --zone $ZONE \
  --platform standard-v3 \
  --memory 8 \
  --cores 2 \
  --core-fraction 100 \
  --network-interface subnet-id=$SUBNET_ID,nat-ip-version=ipv4 \
  --create-boot-disk image-id=$IMAGE_ID,size=30,type=network-hdd \
  --metadata "ssh-keys=ubuntu:${SSH_PUBKEY}"

# Создание трёх worker
for i in 1 2 3; do
  echo "Создание worker-ноды k8s-worker-$i..."
  yc compute instance create \
    --name k8s-worker-$i \
    --folder-id $FOLDER_ID \
    --zone $ZONE \
    --platform standard-v3 \
    --memory 8 \
    --cores 2 \
    --core-fraction 100 \
    --network-interface subnet-id=$SUBNET_ID,nat-ip-version=ipv4 \
    --create-boot-disk image-id=$IMAGE_ID,size=30,type=network-hdd \
    --metadata "ssh-keys=ubuntu:${SSH_PUBKEY}"
done

echo "✅ Все ВМ созданы. Получаем их IP-адреса:"
yc compute instance list --folder-id $FOLDER_ID --format json | jq -r '.[] | [.name, .network_interfaces[0].primary_v4_address.one_to_one_nat.address] | @tsv'