#!/usr/bin/env bash
#

set -e

dir="$1"

_sort() {
	local cate newFile="${1}.tmp"
	echo -n >"${newFile}"
	newFile="$(realpath "$newFile")"
	pushd "$dir"
	while read -r file; do
		cate="${file%.txt}"
		grep "^${cate}/" "$file" >>"$newFile" || echo "skip category: $cate"
	done < <(ls -1 *.txt)
	popd
	sed -E 's/^(.*\s)(-?[[:digit:]]+\.[[:digit:]]+\s%)\s/\2\t\t\1\t/' "$newFile" | sort -r -n >"${newFile%.tmp}"
	rm -f "$newFile"
}

_sort "${dir%.dir}.txt"
