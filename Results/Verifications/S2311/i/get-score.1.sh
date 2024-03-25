#!/bin/bash
#

file="$1"
name="$2"

grep 'achieved tok/s:' "$file" | awk -F' ' '{print $NF"\n"}' | grep -Ev '$[[:space:]]*^' >scores.dir/"$name".txt
wc -l scores.dir/"$name".txt
