# pod-identity webhook

TODO : k8s 1.19 대응

```
openssl req -new -nodes -config conf.cnf -keyout pod-identity-webhook.key -out pod-identity-webhook.csr -batch
```

csr을 base64 디코드한 다음 csr 리소스에 넣고 -> approve 뒤 다시 pod-identity-webhook 시크릿에 tls.key, tls.crt라는 이름의 키로 저장시켜주면 pod-identity-webhook이 알아서 인식한다.
