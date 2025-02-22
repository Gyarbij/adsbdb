#!/bin/bash

# v0.0.5

# CHANGE
MONO_NAME='adsbdb'

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RESET='\033[0m'

DOCKER_GUID=$(id -g)
DOCKER_UID=$(id -u)
DOCKER_TIME_CONT="America"
DOCKER_TIME_CITY="New_York"

PRO=production
DEV=dev

error_close() {
	echo -e "\n${RED}ERROR - EXITED: ${YELLOW}$1${RESET}\n";
	exit 1
}

# $1 any variable name
# $2 variable name
check_variable() {
	if [ -z "$1" ]
	then
		error_close "Missing variable $2"
	fi
}

check_variable "$MONO_NAME" "\$MONO_NAME"

if ! [ -x "$(command -v dialog)" ]; then
	error_close "dialog is not installed"
fi

set_base_dir() {
	local workspace="/workspaces/${MONO_NAME}"
	local server="$HOME/${MONO_NAME}"
	if [[ -d "$workspace" ]]
	then
		BASE_DIR="${workspace}"
	else 
		BASE_DIR="${server}"
	fi
}

set_base_dir


# $1 string - question to ask
ask_yn () {
	printf "%b%s? [y/N]:%b " "${GREEN}" "$1" "${RESET}"
}

# return user input
user_input() {
	read -r data
	echo "$data"
}

# Containers
API="${MONO_NAME}_api"
BACKUP_CONTAINER="${MONO_NAME}_postgres_backup"
BASE_CONTAINERS=("${MONO_NAME}_postgres" "${MONO_NAME}_redis")
ALL=("${BASE_CONTAINERS[@]}" "${API}"  "${BACKUP_CONTAINER}")
TO_RUN=("${BASE_CONTAINERS[@]}")


make_db_data () {
	cd "${BASE_DIR}" || error_close "${BASE_DIR} doesn't exist"
	local db_data="${BASE_DIR}/db_data"
	local pg_data="${db_data}/pg_data"
	local redis_data="${db_data}/redis_data"
	local backups="${db_data}/backups"

	for DIRECTORY in $db_data $pg_data $redis_data $backups
	do
	if [[ ! -d "$DIRECTORY" ]]
	then
		mkdir "$DIRECTORY"
	fi
	done
	cd "${BASE_DIR}/docker" || error_close "${BASE_DIR}/docker doesn't exist"

}

# make_logs_directories () {
# 	cd "${BASE_DIR}" || error_close "${BASE_DIR} doesn't exist"
# 	local logs_dir="${BASE_DIR}/logs"

# 	for DIRECTORY in "${ALL_APPS[@]}"
# 	do
# 	if [[ ! -d "${logs_dir}/$DIRECTORY" ]]
# 	then
# 		mkdir "${logs_dir}/$DIRECTORY"
# 	fi
# 	done
# 	cd "${BASE_DIR}/docker" || error_close "${BASE_DIR}/docker doesn't exist"
# }

make_all_directories() {
	make_db_data
	# make_logs_directories
}

dev_up () {
	make_all_directories
	cd "${BASE_DIR}/docker" || error_close "${BASE_DIR} doesn't exist"
	echo "starting containers: ${TO_RUN[*]}"
	DOCKER_GUID=${DOCKER_GUID} \
	DOCKER_UID=${DOCKER_UID} \
	DOCKER_TIME_CONT=${DOCKER_TIME_CONT} \
	DOCKER_TIME_CITY=${DOCKER_TIME_CITY} \
	docker compose -f dev.docker-compose.yml up --force-recreate --build -d "${TO_RUN[@]}"
}

dev_down () {
	cd "${BASE_DIR}/docker" || error_close "${BASE_DIR} doesn't exist"
	DOCKER_GUID=${DOCKER_GUID} \
	DOCKER_UID=${DOCKER_UID} \
	DOCKER_TIME_CONT=${DOCKER_TIME_CONT} \
	DOCKER_TIME_CITY=${DOCKER_TIME_CITY} \
	docker compose -f dev.docker-compose.yml down
}

production_up () {
	ask_yn "added crontab \"15 3 * * *  docker restart ${MONO_NAME}_postgres_backup\""
	if [[ "$(user_input)" =~ ^y$ ]] 
	then
		make_all_directories
		cd "${BASE_DIR}/docker" || error_close "${BASE_DIR} doesn't exist"
		DOCKER_GUID=${DOCKER_GUID} \
		DOCKER_UID=${DOCKER_UID} \
		DOCKER_TIME_CONT=${DOCKER_TIME_CONT} \
		DOCKER_TIME_CITY=${DOCKER_TIME_CITY} \
		DOCKER_BUILDKIT=0 \
		docker compose -f docker-compose.yml up -d
	else
		exit
	fi
}

production_rebuild () {
	ask_yn "added crontab \"15 3 * * *  docker restart ${MONO_NAME}_postgres_backup\""
	if [[ "$(user_input)" =~ ^y$ ]] 
	then
		make_all_directories
		cd "${BASE_DIR}/docker" || error_close "${BASE_DIR} doesn't exist"
		DOCKER_GUID=${DOCKER_GUID} \
		DOCKER_UID=${DOCKER_UID} \
		DOCKER_TIME_CONT=${DOCKER_TIME_CONT} \
		DOCKER_TIME_CITY=${DOCKER_TIME_CITY} \
		DOCKER_BUILDKIT=0 \
		docker compose -f docker-compose.yml up -d --build
	else
		exit
	fi
}

production_down () {
	cd "${BASE_DIR}/docker" || error_close "${BASE_DIR} doesn't exist"
	DOCKER_GUID=${DOCKER_GUID} \
	DOCKER_UID=${DOCKER_UID} \
	DOCKER_TIME_CONT=${DOCKER_TIME_CONT} \
	DOCKER_TIME_CITY=${DOCKER_TIME_CITY} \
	docker compose -f docker-compose.yml down
}

select_containers() {
	cmd=(dialog --separate-output --backtitle "Dev containers selection" --checklist "select: postgres + redis +" 14 80 16)
	options=(
		1 "$API" off
		2 "$BACKUP_CONTAINER" off
	)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	exitStatus=$?
	clear
	if [ $exitStatus -ne 0 ]; then
		exit
	fi
	for choice in $choices
	do
		case $choice in
			0)
				exit
				break;;
			1)
				TO_RUN=("${TO_RUN[@]}" "${API}")
				;;
			2)
				TO_RUN=("${TO_RUN[@]}" "${BACKUP_CONTAINER}")
				;;
		esac
	done
	dev_up
}

main() {
	echo "in main"
	cmd=(dialog --backtitle "Start ${MONO_NAME} containers" --radiolist "choose environment" 14 80 16)
	options=(
		1 "${DEV} up" off
		2 "${DEV} down" off
		3 "${PRO} up" off
		4 "${PRO} down" off
		5 "${PRO} rebuild" off
	)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	exitStatus=$?
	clear
	if [ $exitStatus -ne 0 ]; then
		exit
	fi
	for choice in $choices
	do
		case $choice in
			0)
				exit
				break;;
			1)
				select_containers
				break;;
			2)
				dev_down
				break;;
			3)
				echo "production up: ${ALL[*]}"
				production_up
				break;;
			4)
				production_down
				break;;
			5)
				production_rebuild
				break;;
		esac
	done
}

main

# ask if setup cron!
# 3 0 * * * docker restart adsbdb_postgres_backup