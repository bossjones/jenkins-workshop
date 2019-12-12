FROM jenkins/jenkins:lts
LABEL maintainer="Jarvis <jarvis@theblacktonystark.com>"
COPY --chown=jenkins init.groovy.d/executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
COPY --chown=jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENV DEBIAN_FRONTEND noninteractive
# we keep separate RUN (layer) for development
USER root

# python3-venv python3-pip
RUN apt-get -y update && \
  apt-get -y install python-minimal python-apt bash-completion curl git vim apt-transport-https ca-certificates curl software-properties-common ipset

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 19.3.1

RUN set -ex; \
  \
  wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
  \
  python3 get-pip.py \
  --disable-pip-version-check \
  --no-cache-dir \
  "pip==$PYTHON_PIP_VERSION" \
  ; \
  pip3 --version; \
  \
  find /usr/local -depth \
  \( \
  \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
  -o \
  \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
  \) -exec rm -rf '{}' +; \
  rm -f get-pip.py

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
