#!/bin/bash

# Удалить существующий Minikube
minikube delete --purge

rm -rf ~/.minikube ~/.kube/config

# Создать новый с нужными параметрами
minikube start --driver=docker --nodes=3 --cpus=2 --memory=2048 --disk-size=20000 --kubernetes-version="v1.35.1"