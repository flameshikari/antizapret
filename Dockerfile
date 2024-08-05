FROM debian:11

COPY scripts/deps.sh /tmp
RUN /tmp/deps.sh

COPY scripts/configs.sh /tmp
RUN /tmp/configs.sh

COPY rootfs/ /
WORKDIR /root/antizapret

ENTRYPOINT [ "/root/init" ]
