#!/usr/bin/env bash

# Find and display label information from [Audacity]() project files (`.aup`).
#
# Given a file name:
# * extract the start, end and title of each label found
# * concatenate the file base name and title, to form a dialog coordinate
# * display coordinates and timing to `stdout`.
#
# The script works on one or multiple file names, given as argument or through `stdin`.
#
# Example `2-1.aup` file:
# <?xml version="1.0" standalone="no" ?>
# <!DOCTYPE [...] >
# <project xmlns=[...]
#	[...]
# 	<labeltrack name="Label Track" numlabels="10" height="73" minimized="0" isSelected="1">
#     <label t="5.1725104681" t1="7.1418036101" title="1"/>
#     <label t="9.9461767555" t1="13.3238884105" title="2"/>
#     [...]
#     <label t="74.8789684769" t1="78.9645313351" title="10"/>
#   </labeltrack>
# </project>
#
# Partial output for the previous file:
# 2-1-1 5.1725104681 7.1418036101
# 2-1-2 9.9461767555 13.3238884105
# [...]
# 2-1-10 74.8789684769 78.9645313351


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

# This script accepts one or multiple file names as arguments or through stdin.
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