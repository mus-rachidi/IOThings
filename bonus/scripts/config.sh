  #!/bin/bash

  YELLOW="\e[33m"
  ENDCOLOR="\e[0m"
  BLUE="\e[34m"

  export EMAIL="murachid@student.42.fr"
  export DOMAIN="localhost"
  # mkdir ~/.kube 2> /dev/null
  # sudo k3s kubectl config view --raw > "$KUBECONFIG"
  # chmod 600 "$KUBECONFIG"
  echo -e "${YELLOW} Create cluster , Creating...${ENDCOLOR}"
  wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash 
  k3d cluster create argocd -p "8888:8888@loadbalancer"  -p "2222:22@loadbalancer"

  echo -e "${YELLOW}=========================Done===========================${ENDCOLOR}"

  echo -e "${YELLOW} Create the namespace dev argocd gitlab, Creating...${ENDCOLOR}"
  kubectl create namespace dev 
  kubectl create namespace argocd 
  echo -e "${YELLOW}=========================Done===========================${ENDCOLOR}"


  echo -e "${YELLOW} apply argocd ...${ENDCOLOR}"
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.5/manifests/install.yaml
  echo -e "${YELLOW}=========================Done===========================${ENDCOLOR}"



  sleep 10
  namespace="argocd"
  while true; do
    running_pods=$(kubectl get pod -n $namespace | grep -c "Running")
    total_pods=$(kubectl get pod -n $namespace | grep -c "argocd-")

    if [ "$running_pods" -eq "$total_pods" ]; then
      
      sleep 10
      echo -e "${YELLOW} Deploy application...${ENDCOLOR}"
      kubectl apply -f ../confs/application.yaml
      echo -e "${YELLOW}=========================Done===========================${ENDCOLOR}" 
      break
    else
      echo -e "${BLUE}Waiting for pods to be in Running state...${ENDCOLOR}"   
    fi
  sleep 5
  done  

  echo -e "${YELLOW} Add Helm repo gitlab ...${ENDCOLOR}"
    helm repo add gitlab https://charts.gitlab.io/
    helm repo update
  echo -e "${YELLOW}=========================Done===========================${ENDCOLOR}"

    echo -e "${YELLOW} install Helm repo gitlab ...${ENDCOLOR}"
    kubectl create namespace gitlab 
    helm install gitlab gitlab/gitlab --set global.hosts.domain=$DOMAIN \
    --set certmanager-issuer.email=$EMAIL \
    --set global.hosts.https="false" \
    --set global.ingress.configureCertmanager="false" \
    --set gitlab-runner.install="false" \
    -n gitlab

 # kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:80     kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 9001:8181