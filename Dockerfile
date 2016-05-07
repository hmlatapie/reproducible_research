from ubuntu:14.04

RUN apt-get update
RUN apt-get upgrade -y

VOLUME /root/rr
WORKDIR /root/images

