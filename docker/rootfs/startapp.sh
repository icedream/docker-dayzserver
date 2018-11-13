#!/bin/bash -ex

# Resolve a path to an absolute path in a way that it can be used inside Wine apps
resolve_path_for_wine() {
	# Is this already a wine-compatible path?
	if [[ "$value" =~ ^[A-Za-z]: ]]
	then
		printf '%s' "$value"
		return 0
	fi

	# Replace \ with /
	value="${value//\\/\/}"

	# Get absolute UNIX path
	value="$(readlink -f "$1")"
	if [ -z "${value}" ]
	then
		# That file does not exist!
		echo "Could not resolve path: ${1}" >&2
		return 1
	fi

	# Replace / with \
	value="${value//\//\\}"

	# Prepend Z: drive location
	value="Z:${value}"

	printf '%s' "$value"
	return 0
}

export HOME=/config

# Initialize missions directory with template if there is none yet
if [ ! -d "${HOME}/mpmissions" ]
then
	cp -vr /opt/dayzserver/mpmissions.template "${HOME}/mpmissions"
fi

# Configure wine non-interactively
WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -eu

# Disable crash dialog
wine regedit /disable_crash_dialog.reg
wineserver -w

# Switch to config directory for predictable path resolving
cd "${HOME}"

# Parse DAYZSERVER_CLI_* variables into -name=value arguments
SERVER_ARGS=()
while IFS='=' read -r name value
do
	name="${name/DAYZSERVER_CLI_/}"
	case "${name}" in
		CONFIG)
			# make absolute path that is valid in Wine
			value="$(resolve_path_for_wine "${value}")"
			;;
	esac
	name="$(tr '[[:upper:]]' '[[:lower:]]' <<< "${name}" | sed -r 's/(_)(([^_])([^_]*))?/\U\3\L\4/g')"
	case "${value}" in
		true|yes)
			SERVER_ARGS+=("-$name")
			;;
		*)
			SERVER_ARGS+=("-$name=$value")
			;;
	esac
done < <(env | grep 'DAYZSERVER_CLI_')

echo "Arguments:" "${SERVER_ARGS[@]}"

exec wine /opt/dayzserver/DayZServer_x64.exe "${SERVER_ARGS[@]}" "$@"
