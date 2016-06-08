FROM gliderlabs/alpine:3.3

RUN apk-install bash grep libxml2 libxml2-utils parallel ffmpeg

COPY extract-label-values.sh /usr/local/bin/extract-label-values
COPY extract-audio-sample.sh /usr/local/bin/extract-audio-sample

ENV audacity_dir="/AudacityProjects"
ENV audio_dir="/Audio"
ENV extracts_dir="/Extracts"
ENV cvs_file="${extracts_dir}/shadowing.csv"

CMD ls ${audacity_dir}/* | extract-label-values | \
	parallel --will-cite --colsep ' ' extract-audio-sample -i ${audio_dir} -o ${extracts_dir} \
	-s {4} -e {5} {1} {2} {3}
