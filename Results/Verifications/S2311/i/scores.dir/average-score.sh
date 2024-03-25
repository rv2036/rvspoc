#!/bin/bash
#

avr() {
	file="$1"
	exp=""
	ln=0

	while read -r line; do
		exp+="$line"
		exp+=" +"
		(( ln++ ))
	done <"$file"

	exp="${exp% +}"
	average=$(echo "scale=6; ( $exp ) / $ln" | bc)

	echo "${file%.txt}: $average" >>summary
}

while read -r line; do
	avr "$line"
done <<<"$(ls -1 *.txt)"
