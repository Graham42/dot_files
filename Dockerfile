# For development on windows.
# Combine boot2docker + this container to get a dev environment
FROM ubuntu:14.04

RUN apt-get update -y
RUN apt-get install -y git
RUN apt-get install -y python
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN apt-get install -y tmux
RUN apt-get install -y build-essential
RUN apt-get install -y man-db

# Setup home environment
RUN groupadd admin
RUN useradd -m -G admin -s /bin/bash dev
RUN passwd -d dev

# Create a shared data volume
# We need to create an empty file, otherwise the volume will belong to root.
# This is probably a Docker bug.
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME /var/shared

WORKDIR /home/dev
ENV HOME /home/dev
ADD . /home/dev/dot_files

USER dev
