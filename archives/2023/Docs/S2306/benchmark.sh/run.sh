#!/usr/bin/env bash
#

set -e
set -o pipefail

#
## source variables
NODE_BENCHMARK_SCRIPT_DIR="$(dirname "$(realpath "$0")")"
. "${NODE_BENCHMARK_SCRIPT_DIR}/var.sh"
. "${NODE_BENCHMARK_SCRIPT_DIR}/cate.sh"

###
##
#

exec {ANOTHER_STDERR}>&2
_do() {
	local pretend=0

	if [[ $1 == "-p" ]]; then
		pretend=1
		shift
	fi
	set -- "$@"

	echo -e "\x1b[1;32m>>>\x1b[0m" "$@" >&$ANOTHER_STDERR

	if [[ $pretend == 0 ]]; then
		"$@"
	fi
}

log() {
	if [[ $1 == "-r" ]]; then
		shift
		echo -ne "\x1b[G\x1b[K"
		echo -ne "\x1b[A\x1b[K"
	fi
	echo -e "\x1b[1;33m  LOG:\x1b[0m \x1b[1m${1}\x1b[0m" >&$ANOTHER_STDERR
}

fatal() {
	echo -e "\x1b[1;31mERROR:\x1b[0m \x1b[1m${1}\x1b[0m" >&$ANOTHER_STDERR
	exit "${2:-1}"
}

is_valid_node_src() {
	[[ -d "${NODE_BENCHMARK_SRCDIR%/}/benchmark" ]] || return 1
	[[ -f "${NODE_BENCHMARK_SRCDIR%/}/benchmark/run.js" ]] || return 1
	[[ -f "${NODE_BENCHMARK_SRCDIR%/}/benchmark/_cli.js" ]] || return 1
	return 0
}

if ! is_valid_node_src; then
	fatal "Please specify a valid node src path!"
fi
_do cd "${NODE_BENCHMARK_SRCDIR}"

##
## some pre works to make all benchmarks successful BEGIN
# This prepare state dir is fixed to under the NODE_BENCHMARK_SRCDIR.
NODE_BENCHMARK_PREPARE_STATE_DIR="${NODE_BENCHMARK_SRCDIR%/}/__node_benchmark_prepare_state.dir"
# This state dir is fixed to under the NODE_BENCHMARK_OUTDIR.
NODE_BENCHMARK_STATE_DIR="${NODE_BENCHMARK_OUTDIR%/}/state.dir"
prepare_napi_binding() {
	! [[ -f "${NODE_BENCHMARK_PREPARE_STATE_DIR}/napi_binding.ready" ]] || return 0

	log "preparing napi binding ..."

	if [[ ! -f ./config.gypi ]]; then
		_do python ./configure.py
	fi
	_do env NODE="${NODE_BENCHMARK_BIN}" make benchmark/napi/.buildstamp

	_do touch "${NODE_BENCHMARK_PREPARE_STATE_DIR}/napi_binding.ready"
}
prepare_misc_eslint() {
	! [[ -f "${NODE_BENCHMARK_PREPARE_STATE_DIR}/misc_eslint.ready" ]] || return 0

	log "preparing misc eslint installation ..."

	trap '
	set -e
	_do touch "${NODE_BENCHMARK_PREPARE_STATE_DIR}/misc_eslint.ready"
	' RETURN

	set +e
	_do "$NODE_BENCHMARK_BIN" -p \
		"require('./tools/node_modules/eslint/package.json').version"
	[[ $? != 0 ]] || return 0
	set -e

	# Due to eslint pkg is missing in the src tarball downloaded from
	# nodejs official website, so check it here.
	local eslint_updater="./tools/dep_updaters/update-eslint.sh"
	[[ -x "$eslint_updater" ]] || _do chmod +x "$eslint_updater"
	# Patch it to make it works without an old eslint.
	! [[ -f "${eslint_updater}.bak" ]] || _do mv "${eslint_updater}.bak" "$eslint_updater"
	_do sed -Ei'.bak' \
		'/^NEW_VERSION=/d;/^CURRENT_VERSION=/d;/^compare_dependency_version/d' \
		"$eslint_updater"
	# Install eslint, with a fixed version, 8.54.0, the version matches the
	# v20.11.0 tag.
	_do mkdir -p ./tools/node_modules
	_do env NODE="$NODE_BENCHMARK_BIN" NEW_VERSION="8.54.0" "$eslint_updater"
}
prepare_permission_patch() {
	! [[ -f "${NODE_BENCHMARK_PREPARE_STATE_DIR}/permission_patch.ready" ]] || return 0

	log "preparing patching for permission category ..."

	# See also: https://github.com/nodejs/node/pull/51528
	# This patch is necessary for permission category until it's been backported.
	_do patch -p1 <"${NODE_BENCHMARK_SCRIPT_DIR}/misc/51528.diff"

	_do touch "${NODE_BENCHMARK_PREPARE_STATE_DIR}/permission_patch.ready"
}
prepare_out_dir() {
	local choice
	log "preparing the out directory ..."

	if [[ -f "${NODE_BENCHMARK_STATE_DIR}/benchmark.begin" ]]; then
		log "a benchmark has already been executed with this out directory:"
		log "  ${NODE_BENCHMARK_OUTDIR}"
		log "continue to override the data that may exist?"
		read -p "  (y/N): " -r choice
		if [[ ! $choice =~ ^[yY]([eE][sS])?$ ]]; then
			fatal "Abort!"
		fi
	fi
	_do mkdir -p "$NODE_BENCHMARK_STATE_DIR"

	local d0 d1 f
	d0=$(uuidgen)
	f="test_file_$d0"
	_do mkdir -p "$NODE_BENCHMARK_OUTDIR"
	_do echo "$d0" >"${NODE_BENCHMARK_OUTDIR%/}/$f"
	d1=$(_do cat "${NODE_BENCHMARK_OUTDIR%/}/$f")
	_do rm "${NODE_BENCHMARK_OUTDIR%/}/$f"
	[[ "$d0" == "$d1" ]] || \
		fatal "Contents are not identical when preparing the out dir."
}
prepare() {
	prepare_out_dir
	_do mkdir -p "$NODE_BENCHMARK_PREPARE_STATE_DIR"
	prepare_napi_binding
	prepare_misc_eslint
	prepare_permission_patch
}
prepare
## some pre works to make all benchmarks successful END
##

##
## collect useful informations BEGIN
declare -A NODE_BENCHMARK_INFO
NODE_BENCHMARK_INFO["node-version"]=$(_do "${NODE_BENCHMARK_BIN}" --version)
# TODO: more informations
# Store these informations into NODE_BENCHMARK_OUTDIR/environment.txt
NODE_BENCHMARK_INFO_FILE="${NODE_BENCHMARK_OUTDIR%/}/environment.txt"
_do echo "" >"$NODE_BENCHMARK_INFO_FILE"
for __KEY in "${!NODE_BENCHMARK_INFO[@]}"; do
	_do printf "%20s: %s\n" "$__KEY" "${NODE_BENCHMARK_INFO[$__KEY]}" >>"$NODE_BENCHMARK_INFO_FILE"
done
## collect useful informations END
##

sub_processes() {
	local pid=$1 p
	NODE_BENCHMARK_CURRENT_PROCESSES+=( $pid )
	while read -r p; do
		if [[ -z $p ]]; then
			continue
		fi
		sub_processes $p
	done <<<"$(pgrep -P $pid || true)"
}
term_processes() {
	local p
	log "PID of sub processes: ${NODE_BENCHMARK_CURRENT_PROCESSES[*]}"
	for p in "${NODE_BENCHMARK_CURRENT_PROCESSES[@]}"; do
		if ps -p $p | grep -v '^[[:space:]]*PID'; then
			_do kill -s SIGTERM $p
		fi
	done
}
NODE_BENCHMARK_CURRENT_SUB_PID_NODE=
NODE_BENCHMARK_CURRENT_SUB_PID_TIME=
NODE_BENCHMARK_CURRENT_PROCESSES=()
NODE_BENCHMARK_SIGINT_CHOICE=
trap '
set +e
echo
log "catch a SIGINT signal ..."
echo
_SUB_TIMEOUT_PID=$(pgrep -P $NODE_BENCHMARK_CURRENT_SUB_PID_NODE)
NODE_BENCHMARK_CURRENT_PROCESSES=()
sub_processes $_SUB_TIMEOUT_PID
term_processes
sleep 0.5
echo

line() { echo "=====================================================" >&${ANOTHER_STDERR}; }
line
read -p "  Continue to benchmark the next category? (y/N): " -r NODE_BENCHMARK_SIGINT_CHOICE
if [[ ! $NODE_BENCHMARK_SIGINT_CHOICE =~ ^[yY]([eE][sS])?$ ]]; then
	line
	exit 130
fi
line
echo
' SIGINT

##
## start benchmark
_do date '+%s' >"${NODE_BENCHMARK_STATE_DIR}/benchmark.begin"

benchmark() {
	local cate cate_dir cate_timeout cate_env ts_begin ts_end ret
	local filter in_filter exclude in_exclude

	for cate in "${NODE_BENCHMARK_CATEGORIES[@]}"; do
		in_filter=0
		in_exclude=0
		if [[ -n ${NODE_BENCHMARK_CATEGORIES_FILTER} ]]; then
			for filter in ${NODE_BENCHMARK_CATEGORIES_FILTER}; do
				if [[ $cate == "$filter" ]]; then
					in_filter=1
					break
				fi
			done
			if [[ $in_filter == 0 ]]; then
				continue
			fi
		fi

		if [[ -n ${NODE_BENCHMARK_CATEGORIES_EXCLUDE} ]]; then
			for exclude in ${NODE_BENCHMARK_CATEGORIES_EXCLUDE}; do
				if [[ $cate == "$exclude" ]]; then
					in_exclude=1
					break
				fi
			done
			if [[ $in_exclude == 1 ]]; then
				continue
			fi
		fi

		log "benchmarking the '${cate}' category ..."
		cate_dir="${NODE_BENCHMARK_OUTDIR%/}/${cate}"
		eval "cate_timeout=\${NODE_BENCHMARK_TIMEOUT_${cate}}"
		eval "cate_env=\"\${NODE_BENCHMARK_ENV_${cate}}\""

		_do mkdir -p "${NODE_BENCHMARK_OUTDIR%/}/${cate}"
		set +e
		ts_begin=$(date '+%s')
		# time
		(
			__first=0
			while :; do
				sleep 1
				ts_end=$(date '+%s')
				printf -v __ts "Duration: %d' %d\"" \
					$(((ts_end - ts_begin) / 60)) \
					$(((ts_end - ts_begin) % 60))
				if [[ $__first == 0 ]]; then
					echo
					__first=1
				fi
				log -r "$__ts"
			done
		) &
		NODE_BENCHMARK_CURRENT_SUB_PID_TIME=$!
		# node
		(
			eval "_do env ${cate_env} \
				timeout $cate_timeout \
				\"${NODE_BENCHMARK_BIN}\" ./benchmark/run.js \
				--format csv \"$cate\" \
				1>\"${cate_dir}/results.txt\" \
				2>\"${cate_dir}/error.txt\""
			_do echo $? >"${cate_dir}/return.code"
			kill -s SIGTERM $NODE_BENCHMARK_CURRENT_SUB_PID_TIME
		) &
		NODE_BENCHMARK_CURRENT_SUB_PID_NODE=$!
		wait $NODE_BENCHMARK_CURRENT_SUB_PID_NODE

		ret=$(cat "${cate_dir}/return.code")
		set -e
		ts_end=$(date '+%s')
		_do echo $(( ts_end - ts_begin )) >"${cate_dir}/duration.txt"

		if (( ret == 124 )); then
			# timeout
			_do touch "${cate_dir}/timeout"
		elif [[ -f "${cate_dir}/timeout" ]]; then
			_do rm "${cate_dir}/timeout"
		fi
	done
}
benchmark

_do date '+%s' >"${NODE_BENCHMARK_STATE_DIR}/benchmark.end"

log "Completed, results are stored in: ${NODE_BENCHMARK_OUTDIR}"
