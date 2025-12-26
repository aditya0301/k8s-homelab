# k8s-homelab
<!-- on kube-master server- run below script to setup kubeconfig -->
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



<!-- when setting up kube master - run below script to disable swap and ip_forwading -->
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo modprobe br_netfilter

sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl -p

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward

