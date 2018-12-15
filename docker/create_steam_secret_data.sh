#!/bin/sh -e

: "${STEAM_USERNAME:=$1}"
: "${STEAM_PASSWORD:=$2}"
: "${STEAM_AUTHCODE:=$3}"

if [ -z "${STEAM_USERNAME}" ]
then
	echo "ERROR: You need to provide a Steam username you want to log in as."
	exit 1
fi

container_name="steam_$(dd if=/dev/urandom bs=128 count=32 | sha256sum - | awk '{print $1}')"
trap 'docker rm -f "${container_name}" >/dev/null' EXIT

docker run --name "${container_name}" -it cm2network/steamcmd \
	/home/steam/steamcmd/steamcmd.sh \
	+login "${STEAM_USERNAME}" "${STEAM_PASSWORD}" "${STEAM_AUTHCODE}" \
	+quit
docker cp "${container_name}:/home/steam/Steam" - > userdata.tar
