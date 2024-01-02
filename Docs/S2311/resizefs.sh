#!/bin/bash
#

SECTORSIZE=512 # bytes
DISK=$(realpath "$1")
PARTNUM=${2:-2}
PARTSIZE=${3:-16G}

set -e

_do() {
	set -- "$@"
	echo -e "\x1b[1;32m>>>\x1b[0m" "$@" >&2
	"$@"
}

_fatal() {
	echo "$@" >&2
	exit 1
}

if [[ $EUID != 0 ]]; then
	_fatal "This script must be executed with a priviledged user!"
fi

# check disk parameter
if [[ -n "$DISK" ]]; then
	if [[ ! -b $DISK ]]; then
		_fatal "The specified file is not a block device!"
	fi
else
	_fatal "Must specify a disk!"
fi

# check transport protocol
TRAN=$(lsblk -d -n -o TRAN "$DISK")
if [[ $TRAN != "usb" ]]; then
	_fatal       "Normally, the TF card should communicate with the system" \
		$'\n'"via a USB interface! But the current transport protocol" \
		$'\n'"is \"$TRAN\"! To avoid damaging this computer's own discs," \
		$'\n'"this script does not support operations in this situation."
fi

# warn user
echo -e "\x1b[1;33;40m"
echo "===================================================="
echo "=== PLEASE PAY ATTENTION TO PROTECT YOUR DATA!!! ==="
echo "===================================================="
echo -ne "\x1b[0m"
echo
echo -e "\x1b[1;31mThe operation will be performed on"
echo -e "          device: \x1b[1;32m$DISK ($(lsblk -d -n -o SIZE "$DISK"))\x1b[1;31m"
echo -e "     partition #: \x1b[1;32m$PARTNUM\x1b[1;31m"
echo -e "  size of sector: \x1b[1;32m$SECTORSIZE bytes\x1b[1;31m"
echo -e "         size to: \x1b[1;32m$PARTSIZE\x1b[0m"
_do lsblk --output NAME,SIZE,FSTYPE,MOUNTPOINT,SERIAL,MODEL,TRAN,TYPE "$DISK"

# confirm action
echo
read -r -p "Confirm? (y/N) " INPUT
if [[ ! $INPUT =~ ^[yY]([eE][sS])?$ ]]; then
	_fatal "Abort!"
fi
echo

# wait
WAIT=5
echo -e "\x1b[1;31mWait for $WAIT seconds,"$'\n'"If here's something wrong, CTRL-C to abort.\x1b[0m"
while [[ ${WAIT} -gt 0 ]]; do
	echo -en "\x1b[1;33m${WAIT} \x1b[m"
		WAIT=$((WAIT -  1))
	sleep 1
done
echo
echo

##########
## MAIN ##
##########

START_SECTOR=$(_do partx -o START -g --nr "$PARTNUM" "$DISK")
PARTITIONS=$(_do partx -l "$DISK" | _do wc -l)

# generate fdisk script
FDISK_SCRIPT=""
gen_fd_script() {
	local i

	FDISK_SCRIPT+=$'\n'"p"
	for (( i=PARTITIONS; i>=PARTNUM; i-- )); do
		FDISK_SCRIPT+=$'\n'"d"
		FDISK_SCRIPT+=$'\n'"$i"
	done
	FDISK_SCRIPT+=$'\n'"n"
	FDISK_SCRIPT+=$'\n'"p"
	FDISK_SCRIPT+=$'\n'"$PARTNUM"
	FDISK_SCRIPT+=$'\n'"$START_SECTOR"
	FDISK_SCRIPT+=$'\n'"+${PARTSIZE#+}"
	FDISK_SCRIPT+=$'\n'"p"
	FDISK_SCRIPT+=$'\n'"w"
}

# do fdisk
gen_fd_script
_do echo "$FDISK_SCRIPT" | _do fdisk "$DISK"

# get partition device
PARTDEV=$(_do echo -e "i\n$PARTNUM"  | _do fdisk "$DISK" | _do awk -F' ' '/^\s*Device:/ {printf $2"\n"}')
PARTSECTORS=$(_do echo -e "i\n$PARTNUM"  | _do fdisk "$DISK" | _do awk -F' ' '/^\s*Sectors:/ {printf $2"\n"}')

_do sync

# resize
_do resize2fs "$PARTDEV" $((PARTSECTORS * SECTORSIZE / 1024))K

# fsck
_do e2fsck -f -p "$PARTDEV"

_do sync
