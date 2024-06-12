#!/gp/bin/bash
#

file="$1"
out="$2"
declare -a story tmp

array_compare() {
	local arrayName1="$1" arrayName2="$2"

	if eval "test \${#$arrayName1[@]} -ne \${#$arrayName2[@]}"; then
		return 1
	fi

	eval "local length=\${#$arrayName1[@]}"
	for (( i=0; i<$length; i++ )); do
		if eval "test \"\${$arrayName1[$i]}\" != \"\${$arrayName2[$i]}\""; then
			return 1
		fi
	done

	return 0 
}

array_echo() {
	local arrayName="$1"
	eval "local length=\${#$arrayName[@]}"
	for (( i=0; i<$length; i++ )); do
		eval "echo \"\${$arrayName[i]}\""
	done
}

while read -r line; do
	if [[ "$line" =~ ^[[:space:]]*$ ]]; then
		tmp[$((${#tmp[@]}-1))]="${tmp[$((${#tmp[@]}-1))]%achieved tok/s:*}"
		if (( "${#story[@]}" > 0 )); then
			if ! array_compare story tmp; then
				echo "Different story!" >&2
				echo "Previous:" >&2
				array_echo story >&2
				echo "New:" >&2
				array_echo tmp >&2
				exit 1
			fi
		else
			for ((i=0; i<${#tmp[@]}; i++)); do
				story[i]="${tmp[i]}"
			done
		fi
		tmp=()
	else
		tmp+=( "$line" )
	fi
done <"$file"

array_echo story >stories.dir/"$out".txt
