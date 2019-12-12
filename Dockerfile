FROM jenkins/jenkins:lts
LABEL maintainer="Jarvis <jarvis@theblacktonystark.com>"
COPY --chown=jenkins init.groovy.d/executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
COPY --chown=jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENV DEBIAN_FRONTEND noninteractive
# we keep separate RUN (layer) for development
USER root
RUN apt-get -y update && \
  apt-get -y install python-minimal python-apt bash-completion curl git vim python3-venv python3-pip apt-transport-https ca-certificates curl software-properties-common ipset

# RUN apt-add-repository ppa:ansible/ansible -y && \
#   apt-get -y update && \
#   apt-get install -y ansible bison build-essential cmake flex git libedit-dev \
#   libllvm6.0 llvm-6.0-dev libclang-6.0-dev python zlib1g-dev libelf-dev luajit luajit-5.1-dev gcc make ncurses-dev libssl-dev bc flex bison libelf-dev libdw-dev libaudit-dev libnewt-dev libslang2-dev
RUN apt-get -y update && \
  apt-get install -y bison build-essential cmake flex git libedit-dev \
  python zlib1g-dev libelf-dev luajit luajit-5.1-dev gcc make ncurses-dev libssl-dev bc bison libelf-dev libdw-dev libaudit-dev libnewt-dev libslang2-dev && \
  pip3 install -U pip wheel && \
  pip3 install ansible

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
  apt-get -y update && \
  apt-get -y install docker-ce-cli
RUN groupadd docker && \
  usermod -a -G docker jenkins && \
  usermod -aG root jenkins
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER jenkins
