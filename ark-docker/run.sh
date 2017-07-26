#!/usr/bin/env bash
echo "###########################################################################"
echo "# Ark Server - " `date`
echo "# UID $UID - GID $GID"
echo "# Args: '$@'"
echo "###########################################################################"
set -eux

export TERM=linux
cd /ark

function setup_ark_data() {
	# Creating directory tree && symbolic link
	[ ! -f /ark/arkmanager.cfg ] && cp /home/steam/arkmanager.cfg /ark/arkmanager.cfg
	[ ! -d /ark/log ] && mkdir /ark/log
	[ ! -d /ark/backup ] && mkdir /ark/backup
	[ ! -d /ark/staging ] && mkdir /ark/staging
	[ ! -L /ark/Game.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/Game.ini Game.ini
	[ ! -L /ark/GameUserSettings.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini GameUserSettings.ini

	if [ ! -d /ark/server  ] || [ ! -f /ark/server/version.txt ]; then
		echo "No game files found. Installing..."
		mkdir -p /ark/server/ShooterGame/Saved/SavedArks
		mkdir -p /ark/server/ShooterGame/Content/Mods
		mkdir -p /ark/server/ShooterGame/Binaries/Linux/
		touch /ark/server/ShooterGame/Binaries/Linux/ShooterGameServer
		arkmanager install
	fi
}

setup_ark_data

"$@"
