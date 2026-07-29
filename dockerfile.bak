FROM rockylinux:9

ARG AGENT_VERSION
ARG MIRROR_URL
ENV AGENT_VERSION=${AGENT_VERSION}
ENV MIRROR_URL=${MIRROR_URL}

RUN dnf update -y && \
    dnf install -y epel-release && \
    dnf install -y wget perl rpm pciutils procps-ng psmisc openssl cronie initscripts cpio tar dkms glibc-langpack-en nano mc && \
    dnf clean all

ENV LANG=en_US.utf8
ENV LC_ALL=en_US.utf8

RUN wget -q -O /opt/CyberProtect_Agent.bin \
        "${MIRROR_URL}/download/u/baas/4.0/${AGENT_VERSION}/CyberProtect_AgentForLinux_x86_64.bin" && \
    chmod +x /opt/CyberProtect_Agent.bin && \
    /opt/CyberProtect_Agent.bin -a --skip-prereq-check --skip-registration --id="BackupAndRecoveryAgent" && \
    rm -f /opt/CyberProtect_Agent.bin

RUN mkdir -p /opt/acronis_template && \
    cp -rp /etc/Acronis /opt/acronis_template/etc && \
    cp -rp /var/lib/Acronis /opt/acronis_template/var && \
    cp -rp /opt/acronis/var /opt/acronis_template/opt_var

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
