FROM ubuntu:16.04

ENV SESSIONNAME="Ark Docker" \
  SERVERMAP="TheIsland" \
  SERVERPASSWORD="" \
  ADMINPASSWORD="adminpassword" \
  NBPLAYERS=70 \
  UPDATEONSTART=1 \
  BACKUPONSTART=1 \
  SERVERPORT=27015 \
  STEAMPORT=7778 \
  BACKUPONSTOP=0 \
  WARNONSTOP=0 \
  UID=1000 \
  GID=1000 \
  MESSAGE_BOT_CONFIG_FILE=/ark/message-bot.yaml

# Install dependencies
RUN apt-get update \
  && apt-get install -y \
     curl \
     lib32gcc1 \
     lsof \
     git \
     ca-certificates \
     jq \
     sudo \
     perl-modules \
     libc6-i386 \
     bzip2 \
     supervisor \
  && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers /etc/sudoers \
  && adduser --disabled-login --shell /bin/bash --gecos "" steam \
  && usermod -a -G sudo steam \
  && touch /root/.bash_profile \
  && mkdir /ark \
  && chown steam -R /ark \
  && chmod 755 -R /ark \
  && curl -sL https://raw.githubusercontent.com/FezVrasta/ark-server-tools/master/netinstall.sh > /tmp/ark-server-tools.sh \
  && chmod +x /tmp/ark-server-tools.sh \
  && /tmp/ark-server-tools.sh steam \
  && rm /tmp/ark-server-tools.sh \
  && mkdir /home/steam/steamcmd \
  && cd /home/steam/steamcmd \
  && curl http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz

# Copy & rights to folders
COPY run.sh /home/steam/run.sh
COPY arkmanager-user.cfg /home/steam/arkmanager.cfg
COPY supervisord.ini /etc/supervisor/conf.d/ark.conf
COPY entrypoint.sh /
# Define default config files in /etc/arkmanager
COPY arkmanager-system.cfg /etc/arkmanager/arkmanager.cfg
COPY instance.cfg /etc/arkmanager/instances/main.cfg

EXPOSE ${STEAMPORT} 32330 ${SERVERPORT}
EXPOSE ${STEAMPORT}/udp ${SERVERPORT}/udp

VOLUME /ark

WORKDIR /ark
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
