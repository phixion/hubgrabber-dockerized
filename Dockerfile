# syntax=docker/dockerfile:1
FROM python:3.11-alpine
LABEL org.opencontainers.image.title='dockerhubGrabber-dockerized'
LABEL org.opencontainers.image.description='dockerized version of https://github.com/SergejFrank/dockerhubGraber'
LABEL org.opencontainers.image.licenses.version='1.0'
LABEL org.opencontainers.image.licenses='MIT'
LABEL org.opencontainers.image.source='https://github.com/phixion/hubgrabber-dockerized/'
ARG WORDLIST
ENV WORDLIST=${WORDLIST}
RUN apk add --no-cache git bash gcc libxml2 libxml2-dev libxslt-dev libc-dev musl-dev
RUN <<EOT bash 
    mkdir -p $PWD/data/app
    mkdir -p $PWD/data/logs
    mkdir -p $PWD/data/wordlists
EOT
WORKDIR /data
RUN git clone https://github.com/SergejFrank/dockerhubGraber app
RUN git clone --depth 1 https://github.com/danielmiessler/SecLists.git wordlists
RUN python3 -m pip install --upgrade pip==23.1.1
WORKDIR /data/app
RUN echo -e '\npython-dotenv==1.0.0' >>requirements.txt
RUN pip install -r requirements.txt
RUN echo -e '#!/usr/bin/env sh \
    set -e \n\
    python3 dockerhubGraber.py \
    -i ../logs/img.txt \
    -k ${WORDLIST} \
    -v' >init.sh
RUN chmod +x init.sh
ENTRYPOINT ["/bin/bash", "init.sh"]
