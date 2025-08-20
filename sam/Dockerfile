## Build Image
# docker build -t sam-runner .

## Run locally
# docker run -it \
#   -v .:/sam/ \
#   -v ./../:/sfd/ \
#   -v /var/run/docker.sock:/var/run/docker.sock
#   sam-runner /bin/bash

FROM python:3.11

RUN apt-get update && \
    apt-get -y upgrade

RUN mkdir /sfd/

ADD sam-requirements.txt sam-requirements.txt

RUN pip install -r requirements.txt

WORKDIR /sfd/
