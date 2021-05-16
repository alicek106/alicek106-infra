# 세팅 방법

원래대로라면 설치, jar 파일 다운로드 등 모든것들을 userdata로 넣으려 헀지만 귀찮아서 그냥 이렇게 남김.

세팅 방법은 별거 없고..

1. ebs 마운트 (fstab 수정)
2. /minecraft/mods, /minecraft/data 디렉터리 생성
3. jar 파일 다운로드 및 /minecraft/mods에 넣는다.
4. 컨테이너를 실행한다 (docker run)

# 마인크래프트 황혼의숲 모드

아래 명령어로 실행한다. 호스트의 /minecraft는 /etc/fstab에서 자동으로 ebs(nvme1n1)에 의해 마운트되어 있어야 한다. 이미지 버전은 무엇을 써도 큰 상관은 없으나, 가능하면 java8을 사용하는 것을 권장하는 듯 하다.

```
docker run -d -p 25565:25565 \
  -v /minecraft/data:/data \
  -v /minecraft/mods:/mods \
  --name mc \
  -e EULA=TRUE \
  -e VERSION=1.12.2 \
  -e TYPE=FORGE \
  --restart always \
  -e FORGEVERSION=14.23.5.2855 \
  itzg/minecraft-server:2021.11.0-java8
```

1.16.5에서 optifine 셰이더는 황혼의숲 모드와 호환되지 않으며 크래시가 발생한다. 이는 known issue이기 때문에 예전 릴리즈 (1.12.2) 를 사용해야 함. 클라이언트도 마찬가지로 서버와 동일한 forge 버전을 세팅하면 된다.

서버 타입이 forge일 경우, mods 디렉터리에 jar 파일을 넣으면 자동으로 /data/mods로 jar 파일이 복사된다. 황혼의숲 jar 파일은 [curseforge](https://www.curseforge.com/minecraft/mc-mods/the-twilight-forest/files)에서 다운로드 가능. 현재 사용중인 jar는 twilightforest-1.12.2-3.11.1021-universal.jar 이다. 

사용 가능한 환경변수에 대해서는 [README](https://github.com/itzg/docker-minecraft-server)를 참고한다.

# route53 + LB-less
원래는 LB에 route53을 물리고 인스턴스를 연결해 사용했으나, LB 요금이 나가므로 route53에서 직접 인스턴스 IP를 향하도록 세팅했다. minecraft 슬랙봇에서 !start_minecraft를 하면 minecraft.alicek106.com 도메인이 자동으로 인스턴스 IP로 설정되도록 해 놓았음. 변경된 인스턴스 IP를 수동으로 route53 도메인에 싱크하려면 !sync_minecraft를 사용한다.
