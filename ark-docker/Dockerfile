FROM ubuntu:14.04

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
  GID=1000

# Install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y curl lib32gcc1 lsof git

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i.bkp -e \
	's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers \
	/etc/sudoers

# Run commands as the steam user
RUN adduser \
	--disabled-login \
	--shell /bin/bash \
	--gecos "" \
	steam
# Add to sudo group
RUN usermod -a -G sudo steam

# Copy & rights to folders
COPY run.sh /home/steam/run.sh
COPY user.sh /home/steam/user.sh
COPY arkmanager-user.cfg /home/steam/arkmanager.cfg

RUN touch /root/.bash_profile \
  && chmod 777 /home/steam/run.sh \
  && chmod 777 /home/steam/user.sh \
  && mkdir /ark

RUN curl -sL https://raw.githubusercontent.com/FezVrasta/ark-server-tools/master/netinstall.sh > /tmp/ark-server-tools.sh \
  && chmod +x /tmp/ark-server-tools.sh  \
  && /tmp/ark-server-tools.sh steam \
  && rm /tmp/ark-server-tools.sh

# Define default config file in /etc/arkmanager
COPY arkmanager-system.cfg /etc/arkmanager/arkmanager.cfg

# Define default config file in /etc/arkmanager
COPY instance.cfg /etc/arkmanager/instances/main.cfg

RUN chown steam -R /ark && chmod 755 -R /ark

#USER steam

# download steamcmd
RUN mkdir /home/steam/steamcmd &&\
	cd /home/steam/steamcmd &&\
	curl http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -vxz

# First run is on anonymous to download the app
# We can't download from docker hub anymore -_-
#RUN /home/steam/steamcmd/steamcmd.sh +login anonymous +quit

EXPOSE ${STEAMPORT} 32330 ${SERVERPORT}
# Add UDP
EXPOSE ${STEAMPORT}/udp ${SERVERPORT}/udp

VOLUME  /ark

# Change the working directory to /arkd
WORKDIR /ark

# Update game launch the game.
ENTRYPOINT ["/home/steam/user.sh"]
