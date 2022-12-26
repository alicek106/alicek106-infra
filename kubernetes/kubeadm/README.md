# kubeadm terraform

자동으로 kubeadm 클러스터를 띄워주는 테라폼 코드

## Needs
- 필요할때 바로 띄우고, 필요없으면 바로 내릴 수 있는 쿠버 클러스터가 있었으면 좋겠다.
- EKS를 쓰면 가장 좋겠지만, EKS는 컨트롤 플레인 요금이 청구된다.
- 그래서 EKS를 항상 켜놓기는 조금 부담스러우니 언제든지 띄웠다가 내릴 수 있는 static aws instance 기반 kubeadm 클러스터를 동적으로 만들고 부술수 있도록 구성하였다.

## How to use
vpc_network 모듈을 먼저 apply한 뒤, kubernetes 워크스페이스의 네트워크 인프라를 output으로 가져다 쓴다. 주의할 점은 아래와 같다.
- var.initialize_kubeadm을 true로 설정하면 자동으로 kubeadm 클러스터 설치가 된다.
- 네트워크 애드온은 수동으로 설치해야 한다.
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml -O
kubectl apply -f custom-resources.yaml
```
- [ec2-connect](https://github.com/alicek106/go-ec2-ssh-autoconnect) group start kubeadm으로 클러스터를 띄우고, ec2-connect group stop kubeadm으로 클러스터를 내린다.
- [alicek106-dotfile](https://github.com/alicek106/alicek106-dotfile)의 akemi.sh를 사용해 쿠버 context의 API 엔드포인트를 설정한다.

