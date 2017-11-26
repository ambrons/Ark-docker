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
	[ ! -f /ark/log/arkserver.log ] && touch /ark/log/arkserver.log
        [ ! -f /ark/log/arkmanager.log ] && touch /ark/log/arkmanager.log
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

function wrapped_start() {
	if [ ${BACKUPONSTART} -eq 1 ]; then
		echo "[Backup]"
		arkmanager backup
	fi

	# Run in the foreground:
	local start_args="$@"
	if [ $UPDATEONSTART -eq 0 ]; then
		start_args="--noautoupdate $start_args"
	fi
	# Launching ark server
	arkmanager start "$start_args"
}

function wrapped_stop() {
	if [ ${BACKUPONSTOP} -eq 1 ]; then
		echo "[Backup on stop]"
		arkmanager saveworld
		arkmanager backup
	fi
	if [ ${WARNONSTOP} -eq 1 ];then
		main stop --warn "$@"
	else
		arkmanager stop "$@"
	fi
}

function discord_message() {
	curl $(cat /ark/discord.json | jq -r '.webhookURL') \
		--data "{\"content\":\"$1\"}"
}

function wrapped_update() {
	echo "Querying Steam database for latest version..."

	players=$(numPlayersConnected)
  if isUpdateNeeded; then
		if [[ "$players" == "0" ]]; then
			discord_message "Current version: $instver\nAvailable version: $bnumber\nUpdating now (nobody is online)"
			arkmanager update "$@"
		else
			discord_message "Current version: $instver\nAvailable version: $bnumber\nUpdating later ($players online)"
			arkmanager update --warn "$@"
		fi
	else
		echo "Server is up to date ($instver == $bnumber)"
	fi
}

function wrapped_main() {
	command="$1"
	shift

	case "$command" in
		start)
			wrapped_start "$@"
		;;
		stop)
			wrapped_stop "$@"
		;;
		update)
			wrapped_update "$@"
		;;
		*)
			arkmanager "$command" "$@"
		;;
	esac
}

setup_ark_data

"$@"
