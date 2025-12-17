# download and install argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# install argocd from manifest
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# patch argocd server to allow insure connection
kubectl patch configmap argocd-cmd-params-cm -n argocd   --type merge   -p '{"data":{"server.insecure":"true"}}'
# verify configmap
kubectl get configmap argocd-cmd-params-cm -n argocd -o yaml | grep -Hn server.insecure
# rollout argocd-server deployment
kubectl rollout restart deployment argocd-server -n argocd

sleep 20
# patch argocd-server service to convert to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc/argocd-server -n argocd
# get admin user password
echo "-----------------"
PASSWD=`echo $(kubectl -n argocd get secrets argocd-initial-admin-secret -o yaml | grep password | awk -F: '{ print $2 }') | base64 -d`
echo $PASSWD
echo "-----------------"
# get port to aceess argocd UI
NODE_PORT=$(kubectl get svc/argocd-server -n argocd | awk -F: '{ print $2 }'  | cut -d'/' -f1 | xargs)
echo $NODE_PORT
sleep 20
# login and create default Application
argocd login localhost:$NODE_PORT
kubectl config set-context --current --namespace=argocd
argocd app create argocd --repo https://github.com/aditya0301/k8s-homelab.git --path argocd/k8s/overlays/shared --dest-server https://kubernetes.default.svc --dest-namespace default





