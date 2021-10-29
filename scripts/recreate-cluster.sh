/usr/local/bin/k3s-uninstall.sh
./k3s.sh

cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

kubectl create namespace confluent
kubectl config set-context --current --namespace confluent

echo "--------------------------- Install Docker secrets ---------------------------"
kubectl create secret generic regcred   --from-file=.dockerconfigjson=$HOME/.docker/config.json    --type=kubernetes.io/dockerconfigjson

echo "--------------------------- Install Kafka ---------------------------"
./init-kafka.sh


echo "--------------------------- Deploy Project ---------------------------"
kubectl apply -f ../deployment/refactored/microservices --recursive

kubectl wait --for=condition=ready pod -l app=postgres-persons
sh run_person_db_command.sh `kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep postgres-person`
kubectl wait --for=condition=ready pod -l app=postgres-locations
sh run_location_db_command.sh `kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep postgres-location`
