FROM rockylinux:9-minimal

ARG AGENT_VERSION
ARG MIRROR_URL

ENV AGENT_VERSION=${AGENT_VERSION} \
    MIRROR_URL=${MIRROR_URL} \
    LANG=en_US.utf8 \
    LC_ALL=en_US.utf8

RUN set -eux; \
    microdnf update -y; \
    microdnf install -y epel-release; \
    microdnf install -y --nodocs \
        wget \
        perl \
        rpm \
        pciutils \
        procps-ng \
        psmisc \
        openssl \
        cronie \
        initscripts \
        cpio \
        tar \
        dkms \
        glibc-langpack-en \
        python3 \
    ; \
    microdnf clean all; \
    rm -rf /var/cache/dnf /var/cache/yum; \
    wget -q -O /opt/CyberProtect_Agent.bin \
        "${MIRROR_URL}/download/u/baas/4.0/${AGENT_VERSION}/CyberProtect_AgentForLinux_x86_64.bin"; \
    chmod +x /opt/CyberProtect_Agent.bin; \
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
