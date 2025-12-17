curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch configmap argocd-cmd-params-cm -n argocd   --type merge   -p '{"data":{"server.insecure":"true"}}'
kubectl get configmap argocd-cmd-params-cm -n argocd -o yaml | grep -Hn server.insecure
kubectl rollout restart deployment argocd-server -n argocd

echo $(kubectl -n argocd get secrets argocd-initial-admin-secret -o yaml | grep password | awk -F: '{ print $2 }') | base64 -d
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc/argocd-server -n argocd

echo "-----------------"
PASSWD=`echo $(kubectl -n argocd get secrets argocd-initial-admin-secret -o yaml | grep password | awk -F: '{ print $2 }') | base64 -d`
echo $PASSWD
echo "-----------------"

argocd login localhost:32641
kubectl config set-context --current --namespace=argocd
argocd app create argocd --repo https://github.com/aditya0301/k8s-homelab.git --path argocd/k8s/overlays/shared --dest-server https://kubernetes.default.svc --dest-namespace default