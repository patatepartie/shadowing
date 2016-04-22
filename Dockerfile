FROM gliderlabs/alpine:3.3

RUN apk-install bash grep libxml2 libxml2-utils parallel ffmpeg

COPY extract-label-values.sh /usr/local/bin/extract-label-values
COPY extract-audio-sample.sh /usr/local/bin/extract-audio-sample

WORKDIR /work