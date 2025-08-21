FROM python:3.11

RUN apt-get update && \
    apt-get -y upgrade

RUN mkdir /sam/

ADD sam-requirements.txt sam-requirements.txt

RUN pip install -r sam-requirements.txt

WORKDIR /sam/
