#!/usr/bin/env bash
#

_do() {
	echo ">>>" "$@" >&2
	"$@"
}

echo >time.txt
while read -r file; do
	_do grep -E "^\"${file%%.*}" "$file" >"${file}.valid"
	ta=( $(cat "${file}.valid" | awk -F' ' '{printf $NF"\n"}') )
	tt=0
	for t in "${ta[@]}"; do
		tt=$( echo "scale=3; $tt + $t" | bc )
	done
	tt=${tt%.*}
	printf "%3d %20s: %d' %d\"\n" $((tt/60)) "${file%%.*}" $((tt/60)) $((tt%60)) >>time.txt
done <<<"$(ls -1 *.results.txt)"
