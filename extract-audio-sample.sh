#!/usr/bin/env bash

function print_help {
	usage="$(basename "${prog_name}") [[infile options] -id indir]... [[outfile options] -od outdir]... ARGS...
	extract a sample of an audio file, and name it based on a pattern filed by ARGS.
	The dash-separated arguments and the file path will be output.

	Example: $(basename "${prog_name}") -p "*_$1_$2_$3.ogg" -P "$3-$2-$1" a 23 z
	will read a file matching the glob pattern '*_a_23_z.ogg' and write a file named 'z-23-a.mp3'.

where:
    -h  show this help text
    -s  start time of the sample to extract (in fractional seconds, default: beginning of input file)
    -e  end time of the sample to extract (in fractional seconds, default: end of input file)
    -i  directory of the input audio file (default: 'inputs')
    -p  pattern of the input audio file. It can use any positional arguments 
        (default: '*_Unit_${1}_-_Section_${2}.mp3')
    -c  codec of the extracted sample audio file (default: mp3)
    -o  directory to output the sample file to (default: 'outputs')
    -P  pattern of the extracted sample audio file. 
        It can use any positional arguments (default: '${1}-${2}-${3}.${codec}')
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
input_pattern='*_Unit_${1}_-_Section_${2}.mp3'
codec="mp3"
output_dir="outputs"
output_pattern='${1}-${2}-${3}.${codec}'

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

eval input_path="${input_dir}/${input_pattern}"
eval output_file="${output_pattern}"
output_path="${output_dir}/${output_file}"

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

echo "${1}-${2}-${3},[sound:${output_file}]"
