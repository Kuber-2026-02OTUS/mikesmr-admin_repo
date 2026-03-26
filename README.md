# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2026-02" 
Адрес ВМ:
ВМ: demo
Логин: mike
SSH: ssh-key-1774100800420
строка подключения: 
ssh -l mike 
ssh -i "C:\Users\AntApart\.ssh\ssh-key-1774100800420" mike@158.160.82.183

yc compute ssh \ --id epdneb77r7p31vrst026 \ --identity-file "C:\Users\AntApart\.ssh\ssh-key-1774100800420" \ --login mike

curl -LO https://dl.k8s.io/release/1.38.1 curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl

curl -LO https://dl.k8s.io/release/v1.38.1/bin/linux/amd64/kubectl

curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64