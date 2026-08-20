FROM debian:bookworm-slim

ARG AGENT_VERSION
ARG MIRROR_URL

ENV AGENT_VERSION=${AGENT_VERSION} \
    MIRROR_URL=${MIRROR_URL} \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        wget \
        perl \
        rpm \
        pciutils \
        procps \
        psmisc \
        openssl \
        cron \
        cpio \
        tar \
        python3 \
        ca-certificates \
        curl \
        locales; \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; \
    locale-gen; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    wget -q -O /opt/CyberProtect_Agent.bin \
        "${MIRROR_URL}/download/u/baas/4.0/${AGENT_VERSION}/CyberProtect_AgentForLinux_x86_64.bin"; \
    chmod +x /opt/CyberProtect_Agent.bin; \
    # Fix for Debian Trixie: disable RPM unshare plugin which fails in unprivileged docker builds
    mv /usr/bin/rpm /usr/bin/rpm.orig; \
    echo '#!/bin/bash' > /usr/bin/rpm; \
    echo 'exec /usr/bin/rpm.orig --noplugins "$@"' >> /usr/bin/rpm; \
    chmod +x /usr/bin/rpm; \
    # Install Acronis Agent
    yes | /opt/CyberProtect_Agent.bin -a --skip-prereq-check --skip-registration --skip-svc-start --id="BackupAndRecoveryAgent"; \
    rm -f /opt/CyberProtect_Agent.bin; \
    # Restore RPM
    mv /usr/bin/rpm.orig /usr/bin/rpm; \
    # Optimize: Remove kernel modules, bootable media, and active protection to save space/resources
    rpm -e --nodeps dkms snapapi26_modules file_protector BackupAndRecoveryBootableComponents || true; \
    rm -f /etc/init.d/acronis_active_protection /etc/init.d/acronis_schedule; \
    # Clean temporary Acronis files
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
