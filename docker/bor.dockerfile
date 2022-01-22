FROM maticnetwork/bor:v0.2.13

RUN apk add jq bash curl

COPY ./docker/bor.start.sh /usr/local/bin/bor.start.sh

ENTRYPOINT ["bash", "/usr/local/bin/bor.start.sh"]