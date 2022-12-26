#!/bin/bash -xe

KUBERNETES_VERSION="${kubernetes_version}"

# kernel module load
cat > /etc/modules-load.d/k8s.conf << '__EOF_MODULES'
overlay
br_netfilter
__EOF_MODULES

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat > /etc/sysctl.d/k8s.conf << '__EOF_K8S_CONF'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
__EOF_K8S_CONF

# Apply sysctl params without reboot
sudo sysctl --system

# kubernetes install
KUBERNETES_VERSION="${kubernetes_version}"

apt-get update
apt-get install -y apt-transport-https curl

curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update

apt-get install -y kubelet=$KUBERNETES_VERSION \
  kubeadm=$KUBERNETES_VERSION \
  kubectl=$KUBERNETES_VERSION

apt-mark hold kubelet kubeadm kubectl

# containerd, runc, cni
cd /tmp
wget https://github.com/containerd/containerd/releases/download/v1.6.14/containerd-1.6.14-linux-amd64.tar.gz
tar xvf containerd-1.6.14-linux-amd64.tar.gz
mv bin/* /usr/local/bin/
wget https://raw.githubusercontent.com/containerd/containerd/release/1.6/containerd.service
mv containerd.service /lib/systemd/system/containerd.service

mkdir -p /etc/containerd/
cat > /etc/containerd/config.toml << '__EOF_CONTAINERD_SPEC'
version = 2

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
            # https://github.com/containerd/containerd/issues/6964#issuecomment-1132378279
            runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            # https://github.com/containerd/containerd/issues/4900
            # https://stackoverflow.com/a/73141339
            SystemdCgroup = true
            # https://github.com/containerd/containerd/discussions/5413
__EOF_CONTAINERD_SPEC

systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz

# Set hostname for cloud provider
hostnamectl set-hostname $(curl http://169.254.169.254/latest/meta-data/local-hostname)

until $(curl --output /dev/null --silent --fail https://${apiserver_ip}:6443/healthz -k); do
    printf '.'
    sleep 5
done

echo "API Server is running!"

cat > /tmp/worker.yaml << '__EOF_KUBEADM_SPEC'
${worker_config}
__EOF_KUBEADM_SPEC

HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
sed -i 's/NODE_HOSTNAME/'"$HOSTNAME"'/g' /tmp/worker.yaml

# Run kubeadm
kubeadm join \
  --config /tmp/worker.yaml
