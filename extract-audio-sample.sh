#!/usr/bin/env bash

# $0 -s 9.9461767555 -e 13.3238884105 -d 2-1-1 -id Audio -ip '*_Unit_${unit}_-_Section_${section}.mp3' \
#    -c mp3 -od Extracts -op '${out_dir}/${unit}-${section}-${dialog}.${codec}'

function print_help {
	usage="$(basename "${prog_name}") [[infile options] -id indir]... [[outfile options] -od outdir]...  UNIT SECTION DIALOG
	extract a sample of an audio file, and name it based on its coordinates: UNIT, SECTION and DIALOG.
	The coordinates and the file path will be output.

where:
    -h  show this help text
    -s  start time of the dialog to extract (in fractional seconds, default: beginning of input file)
    -e  end time of the dialog to extract (in fractional seconds, default: end of input file)
    -i  directory of the input shadowing audio file (default: 'inputs')
    -p  pattern of the input shadowing audio file. It can use 'unit' and 'section' variables 
        (default: '*_Unit_${unit}_-_Section_${section}.mp3')
    -c  codec of the extracted dialog audio file (default: mp3)
    -o  directory to output the dialog file (default: 'outputs')
    -P  pattern of the extracted dialog audio file. 
        It can use 'unit', 'section', 'dialog' and 'codec' variables.
        (default: '${unit}-${section}-${dialog}.${codec}')
    -v  verbose mode, mainly for ffmpeg
    "
	echo "${usage}"
}

function param_error {
	echo "${1}" >&2
	print_help >&2
	exit 1
}

prog_name=${0}

input_dir="inputs"
input_pattern='*_Unit_${unit}_-_Section_${section}.mp3'
codec="mp3"
output_dir="outputs"
output_pattern='${unit}-${section}-${dialog}.${codec}'

# TODO use silent mode when debug is done (prefix by ":"")
while getopts "hvs:e:i:p:c:o:P:" opt; do
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
		i)
			input_dir="${OPTARG}"
			;;
		p)
			input_pattern="${OPTARG}"
			;;
		c)
			codec="${OPTARG}"
			;;
		o)
			output_dir="${OPTARG}"
			;;
		P)
			output_pattern="${OPTARG}"
			;;
		v)
			verbose="true"
			;;
		\?)
			param_error "Invalid option: -${OPTARG}."
			;;
		:)
			param_error "Option -${OPTARG} requires an argument."
			;;
	esac
done

shift $((OPTIND-1))

unit="${1}"
section="${2}"
dialog="${3}"

if [ -z "${unit}" ] || [ -z "${section}" ] || [ -z "${dialog}" ]; then
    param_error "3 positional parameters needs to be set: UNIT SECTION DIALOG."
fi

eval input_path="${input_dir}/${input_pattern}"
eval output_path="${output_dir}/${output_pattern}"

ffmpeg_cmd="ffmpeg -hide_banner -i ${input_path}"
if [ -z "${verbose}" ]; then
	ffmpeg_cmd="${ffmpeg_cmd} -loglevel panic"
fi

if [ ! -z "${start_time}" ]; then
	ffmpeg_cmd="${ffmpeg_cmd} -ss ${start_time}"
fi

if [ ! -z "${end_time}" ]; then
	ffmpeg_cmd="${ffmpeg_cmd} -to ${end_time}"
fi

ffmpeg_cmd="${ffmpeg_cmd} -acodec ${codec} ${output_path}"

`${ffmpeg_cmd}`

echo "${unit}-${section}-${dialog},${output_path}"
