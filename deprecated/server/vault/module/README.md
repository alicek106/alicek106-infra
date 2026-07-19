# vault configuration

vault는 LB 등으로 접근할 때, standby가 요청을 받았을 경우 다른 active에게로 접근하도록 클라이언트에게 307 redirect를 내려줄수도 있고, 요청을 포워딩할수도 있다. 아래 두 옵션은 이를 위한 것이며, 어떤 방식을 사용할 지는 클라이언트 측에서 결정하게 된다.

- api_addr : 클라이언트 redirection을 위해 다른 vault 서버에게 advertising하기 위한 주소. standby로 접근할 경우, active로 요청을 redirection할 때 쓰인다.
- cluster_addr : standby로 요청이 들어왔을 경우, 다른 vault 서버에게 요청을 포워딩할 때 쓰이는 advertising 주소.
- listener["tcp"].address : API를 위한 서버 바인딩. api_addr로 요청이 갔을 때 이 address에서 처리할 수 있어야 함 (ex. api_addr은 프록시 주소지만, address는 로컬에서 바인딩할 주소를 나타낸다)
- listener["tcp"].cluster_address : Cluster간 통신을 위한 서버 바인딩. 일반적으로 8201 포트를 씀 (세팅하지 않으면 address: 포트 + 1 로 설정됨). cluster_addr로 간 클러스터 요청은 listener의 cluster_address에서 처리할 수 있어야 한다.

근데 0.6.2+ 버전에서는 요청 포워딩이 자동으로 활성화되어 있다 (X-Vault-No-request-Forwarding 헤더를 활성화해서 리다이렉션도 가능). 근데 LB 환경에서 리다이렉션을 쓰면 무한루프가 발생할 수 있으므로 포워딩을 디폴트로 쓴다. 어차피 디폴트가 포워딩이라 리다이렉션은 크게 신경쓰지 않아도 될듯 하다.

참고로 웹 UI는 포워딩이 안된다. 무조건 active 노드로 접속해야 함.

# see also
- https://www.vaultproject.io/docs/configuration#high-availability-parameters
- https://www.vaultproject.io/docs/concepts/ha#direct-access
