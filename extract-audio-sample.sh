#!/usr/bin/env bash

# $0 -s 9.9461767555 -e 13.3238884105 -d 2-1-1 -id Audio -ip '*_Unit_${unit}_-_Section_${section}.mp3' \
#    -c mp3 -od Extracts -op '${out_dir}/${unit}-${section}-${dialog}.${codec}'

function print_help {
	usage="$(basename "${prog_name}") [-h] [-s n] -- extract a shadowing dialog from an audio file

where:
    -h  show this help text
    -s  start time of the dialog to extract (in fractional seconds)
    -e  end time of the dialog to extract (in fractional seconds)
    -d  coordinate of the dialog in the format 'UNIT-SECTION-DIALOG' (eg: 1-5-2)
    -id directory of the input shadowing audio file
    -ip pattern of the input shadowing audio file. It can use 'unit' and 'section' variables 
        (eg: *_Unit_${unit}_-_Section_${section}.mp3)
    -c  codec of the extracted dialog audio file (default: mp3)
    -od directory to output the dialog file
    -op pattern of the extracted dialog audio file. 
        It can use 'out_dir', 'unit', 'section', 'dialog' and 'codec' variables.
        (default: '${out_dir}/${unit}-${section}-${dialog}.${codec}')
    "
	echo "${usage}"
}

function param_error {
	echo "$0" >&2
	print_help >&2
	exit 1
}

prog_name=$0

# TODO use silent mode when debug is done (prefix by ":"")
while getopts "hs:e:d:i:p:c:o:" opt; do
	shift $((OPTIND-1))
	case $opt in
		h)
			print_help
			exit 0
			;;
		s)
			start_time="${OPTARG}"
			;;
		e)
			end_time="${OPTARG}"
			;;
		d)
			coordinate_expr="${OPTARG}"
			;;
		id)
			source_dir="${OPTARG}"
			;;
		ip)
			file_pattern="${OPTARG}"
			;;
		c)
			codec="${OPTARG}"
			;;
		od)
			out_dir="${OPTARG}"
			;;
		op)
			out_file="${OPTARG}"
			;;
		\?)
			param_error "Invalid option: -${OPTARG}."
			;;
		:)
			param_error "Option -${OPTARG} requires an argument."
			;;
	esac
done

# source_dir="Audio"
# start_time="9.9461767555"
# end_time="13.3238884105"
# duration=${end_time} - ${start_time}
# page="2-1"
# splits=(${page//-/ })
# unit="${splits[0]}"
# section="${splits[1]}"
# dialog="${splits[2]}"
# file_pattern="*_Unit_${unit}_-_Section_${section}.mp3"
# source_file=`find ${source_dir} -name ${file_pattern}`
# out_dir="Extracts"
# codec="mp3"
# out_file="${out_dir}/${unit}-${section}-${dialog}.${codec}"


# ffmpeg -ss ${start_time} -t ${duration} -acodec ${codec} -i ${source_file} ${out_file}