#!/bin/bash -e

PROCESSES=()

log() {
	echo "[entrypoint]" "$@"
}

terminate_subprocesses() {
	signal="${1:-TERM}"
	if [ "${#PROCESSES[@]}" -gt 0 ]; then
		log "Terminating subprocesses..."
		kill -s "${signal}" "${PROCESSES[@]}" >/dev/null 2>&1 || true
		for (( i = 0; i < 10; i++ )); do
			if ! kill -0 "${PROCESSES[@]}" >/dev/null 2>&1; then
				break
			fi
			sleep 1
		done
		log "Killing remaining subprocesses..."
		kill -9 "${PROCESSES[@]}" >/dev/null 2>&1
	else
		log "No subprocesses to terminate, skipping."
	fi
	PROCESSES=()
	log "Done terminating subprocesses."
}

wait_for_all_subprocesses() {
	log "Now waiting for all subprocesses."
	for pid in "${PROCESSES[@]}"; do
		wait "$pid" 2>/dev/null
	done
	log "Done waiting for all subprocesses."
}

register_subprocess() {
	pid="$!"
	PROCESSES+=("$pid")
	log "Tracking process ID $pid."
}

trap 'terminate_subprocesses TERM' TERM
trap 'terminate_subprocesses INT' INT
trap 'exit 127' INT

# start fake X server
Xorg -noreset +extension RANDR +extension RENDER -logfile /dev/stdout -config /etc/X11/xorg.conf :99 & register_subprocess

export DISPLAY=:99

sleep 1

# start DayZ server
wine /opt/dayzserver/DayZServer_x64.exe "$@" & register_subprocess

# Wait for everything to shut down
wait_for_all_subprocesses

exit 0