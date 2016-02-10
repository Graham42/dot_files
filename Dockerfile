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

RUN mkdir /var/shared/
RUN chown -R dev:dev /var/shared

USER dev
VOLUME /var/shared

WORKDIR /home/dev
ENV HOME /home/dev
ADD . /home/dev/dot_files

RUN /home/dev/dot_files/init_all.sh

CMD ["/bin/bash"]
