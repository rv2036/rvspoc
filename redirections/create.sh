#!/usr/bin/env bash
#

set -e

CURDIR="$(dirname "$(realpath "$0")")"
PUBDIR="$(realpath "${CURDIR}/../public")"

RECORDS_FROM=()
RECORDS_TO=()

_do() {
	echo ">>>" "$@" >&2
	"$@"
}

_sed_Ei() {
	if [[ $IS_BSD_SED == 0 ]]; then
		_do sed -Ei "$@"
	elif [[ $IS_BSD_SED == 1 ]]; then
		_do sed -Ei '' "$@"
	else
		if sed --version &>/dev/null; then
			IS_BSD_SED=0
		else
			IS_BSD_SED=1
		fi
		_sed_Ei "$@"
	fi
}

read_config() {
	local record
	while read -r record; do
		if [[ $record =~ ^[[:space:]]*# ]] || \
			[[ $record =~ ^[[:space:]]*$ ]]; then
			# skip comments and empty lines
			continue
		fi
		if [[ $record =~ ^[[:space:]]*([^[:space:]]+)\ -\>\ ([^[:space:]]+)[[:space:]]*$ ]]; then
			RECORDS_FROM+=( "${BASH_REMATCH[1]}" )
			RECORDS_TO+=( "${BASH_REMATCH[2]}" )
		else
			echo "unrecognized record '$record', skip it.." >&2
			continue
		fi
	done <"${CURDIR}/config"
}

create_one() {
	local from="${1##/}" from_fp to="$2"
	from_fp="${PUBDIR}/${from}"
	_do mkdir -p "$from_fp"
	_do cp "${CURDIR}/tmpl.html" "${from_fp%%/}/index.html"
	if ! [[ $to =~ ^/ ]]; then
		to="/${from%%/}/${to}"
	fi
	_sed_Ei "s@\@TO-PATH\@@${to}@g" "${from_fp%%/}/index.html"
}

echo "creating html redirections..."
read_config
for (( i=0; i<${#RECORDS_FROM[@]}; i++ )); do
	create_one "${RECORDS_FROM[i]}" "${RECORDS_TO[i]}"
done

# vim:sw=8:ts=8:noexpandtab
