docker build -t voting-app-seed-kubernetes:latest -f ../seed-data-kubernetes/Dockerfile ../seed-data-kubernetes
minikube image load voting-app-seed-kubernetes:latest
minikube image load voting-app-worker:latest
minikube image load voting-app-vote:latest
minikube image load voting-app-result:latest

REMOTE_DIR="/mnt/healthchecks"
minikube ssh -- "sudo mkdir -p $REMOTE_DIR"

minikube cp ../healthchecks/redis.sh ${REMOTE_DIR}/redis.sh
minikube cp ../healthchecks/postgres.sh ${REMOTE_DIR}/postgres.sh

minikube ssh -- "sudo chmod +x ${REMOTE_DIR}/*.sh"
