# pod-identity webhook

`이전의 v1beta1에서 생성된 csr들은 모두 signerName이 legacy-unknown 취급되지만, certificates.k8s.io/v1` 부터 signerName에 legacy-unknown을 입력하는 것이 불가능해졌다.  그런데 어쨌든 server auth를 담은 csr을 approve하기는 해야하므로, 쿠버가 제공하는 3가지 유형의 signerName 중 kubernetes.io/kubelet-serving을 사용해야만 한다. 단, 이 signerName은 [몇가지 제한](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#kubernetes-signers)이 있는데,

1. Organization Name이 정확히 system:node 여야 하고,
2. Common Name이 system:node 시작해야 한다. 

이를 적당히 반영한 conf.cnf 파일을 통해 csr을 생성한다.

```
openssl req -new -nodes -config conf.cnf -keyout pod-identity-webhook.key -out pod-identity-webhook.csr -batch
```

생성된 csr을 base64 encode한 뒤, csr의 request 부분에 붙여넣고, apply한 뒤 approve 한다.

```
cat pod-identity-webhook.csr | base64 | pbcopy

# 그리고 나서 csr.yaml에서 request 부분에 붙여넣기 한 뒤, csr을 생성한다.
kubectl apply -f csr.yaml
kubectl certificate approve pod-identity-webhook
```

그 뒤에 pod-identity-webhook 시크릿에 tls.key, tls.crt라는 이름의 키로 저장시켜주면 pod-identity-webhook이 알아서 인식한다.

```
kubectl get csr pod-identity-webhook -o jsonpath='{.status.certificate}' | base64 -D > tls.crt
kubectl create secret generic pod-identity-webhook --from-file=tls.crt=tls.crt --from-file=tls.key=pod-identity-webhook.key
```

마지막으로, pod-identity-webhook을 배포한다.

```
kubectl apply -f .
```

pod-identity-webhook 업스트림에서 이걸 해결할때까지는 이렇게 직접 해결해야 한다....
