#!/usr/bin/env bash

# TODO better name for this function
function extract_label_values {
	full_path="$1"
	unit=$(basename "${full_path}" ".aup")

	# Extract all label nodes and insert newline between them
	labels=$(xmllint --xpath "//*[local-name()='labeltrack']/*[local-name()='label']" ${full_path} | sed 's%><%>\n<%g')

	# Extract t, t1 and title from the label node and display them alongside the unit
	# one group per line
	while read -r line; do
	  read t t1 title <<<$(echo ${line} | grep -oP '"\K(\d+\.?\d*)')
	  echo ${unit}-${title} ${t} ${t1}
	done <<< "${labels}"
}

# If we have arguments, iterate over them.
# Otherwise, iterate over each line of stdin.
if [ $# -ge 1 -a -f "$1" ]; then
	while [[ $# -ge 1 ]]; do
		full_path="$1"
		shift

		extract_label_values ${full_path}
	done
else
	while read -r filename; do
		extract_label_values ${filename}
	done
fi