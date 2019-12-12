FROM jenkins/jenkins:lts
LABEL maintainer="Jarvis <jarvis@theblacktonystark.com>"
ENV DEBIAN_FRONTEND noninteractive
# we keep separate RUN (layer) for development
USER root
RUN apt-get -y update && \
  apt-get -y install jq curl apt-transport-https ca-certificates gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
  apt-get -y update && \
  apt-get -y install docker-ce-cli
RUN groupadd docker && \
  usermod -a -G docker jenkins && \
  usermod -aG root jenkins
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER jenkins
