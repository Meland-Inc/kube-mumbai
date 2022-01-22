FROM maticnetwork/heimdall:v0.2.4

COPY ./docker/heimdall.start.sh /usr/local/bin/heimdall.start.sh

ENTRYPOINT ["bash", "/usr/local/bin/heimdall.start.sh"]