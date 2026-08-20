FROM alpine:latest

ARG AGENT_VERSION
ARG MIRROR_URL

ENV AGENT_VERSION=${AGENT_VERSION} \
    MIRROR_URL=${MIRROR_URL} \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc \
    GLIBC_VERSION=2.35-r1

RUN set -eux; \
    apk update; \
    apk add --no-cache \
        bash \
        wget \
        perl \
        rpm \
        pciutils \
        procps \
        psmisc \
        openssl \
        dcron \
        cpio \
        tar \
        python3 \
        ca-certificates \
        curl; \
    # Install sgerrand glibc to allow proprietary binaries to run on Alpine
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    wget ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk; \
    wget ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk; \
    wget ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk; \
    apk add --no-cache --force-overwrite \
        glibc-${GLIBC_VERSION}.apk \
        glibc-bin-${GLIBC_VERSION}.apk \
        glibc-i18n-${GLIBC_VERSION}.apk; \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8; \
    rm glibc-*.apk; \
    # Needed for Acronis legacy services scripts
    mkdir -p /etc/init.d; \
    wget -q -O /opt/CyberProtect_Agent.bin \
        "${MIRROR_URL}/download/u/baas/4.0/${AGENT_VERSION}/CyberProtect_AgentForLinux_x86_64.bin"; \
    chmod +x /opt/CyberProtect_Agent.bin; \
    # Install Acronis Agent
    /opt/CyberProtect_Agent.bin -a --skip-prereq-check --skip-registration --id="BackupAndRecoveryAgent"; \
    rm -f /opt/CyberProtect_Agent.bin; \
    # Очистка временных файлов агента (пересоздаются при первом запуске)
    rm -rf /opt/acronis/var/aakore/*.db* \
           /opt/acronis/var/siem-connector/*.db* \
           /etc/Acronis/aakore.reg \
           /var/lib/Acronis/*.log \
           /opt/acronis/var/log/*; \
    mkdir -p /opt/acronis_template; \
    cp -rp /etc/Acronis /opt/acronis_template/etc; \
    cp -rp /var/lib/Acronis /opt/acronis_template/var; \
    cp -rp /opt/acronis/var /opt/acronis_template/opt_var; \
    rm -rf /etc/Acronis /var/lib/Acronis /opt/acronis/var

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
