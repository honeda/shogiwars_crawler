#################################################
# Tested Base Docker image: Ubuntu 20
# User: root
#################################################

###### BASIC SETTINGS ##########

# Base docker image
ARG BASE=ubuntu:20.04
FROM ${BASE}

# Prevents error when installation triggers dialog box
ENV DEBIAN_FRONTEND=noninteractive

# Timezone
ENV TZ Asia/Tokyo

EXPOSE 22
EXPOSE 8888
EXPOSE 8889

# Installing basic dev tools
RUN apt-get update -yq && apt-get install software-properties-common -yq
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
RUN apt-get update -yq && \
    apt-get install -yq make build-essential libssl-dev zlib1g-dev git && \
    apt-get install -yq libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev && \
    apt-get install -yq libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl && \
    apt-get install -yq nano vim tmux openssh-server && \
    apt-get install -yq language-pack-ja-base language-pack-ja fontconfig && \
    apt-get install -yq python3-distutils

# Install JP fonts and clear font cache
RUN apt-get install fonts-takao-mincho fonts-takao-gothic fonts-takao-pgothic && \
    fc-cache -fv

###### DEVELOPMENT ENVIRONMENT INSTALLATION ##########

# Install Pyenv
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/shims:$PATH"' >> ~/.bashrc && \
    echo 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.bashrc

# Install python 3.8.6 and set global
RUN ["/bin/bash", "-c", "source ~/.bashrc"]
RUN $HOME/.pyenv/bin/pyenv install 3.8.6 && \
    $HOME/.pyenv/bin/pyenv global 3.8.6

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
    echo 'export PATH="$HOME/.poetry/bin:$PATH"' >> ~/.bashrc
RUN ["/bin/bash", "-c", "source ~/.bashrc"]
RUN $HOME/.poetry/bin/poetry config virtualenvs.in-project true

###### DEVELOPMENT CUSTOMIZATION <OPTIONAL FOR CONTAINER REPLICATION> ##########

# Setting SSH
RUN mkdir /var/run/sshd && \
    echo "root:root" | chpasswd && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config

ENV HOME /root

# Code-server installation and settings
# RUN curl -fOL https://github.com/cdr/code-server/releases/download/v3.4.1/code-server_3.4.1_amd64.deb && \
#     dpkg -i code-server_3.4.1_amd64.deb && \
#     code-server --version

# Installing nodejs for jupyterlab extensions
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -  && \
    apt-get -yq install nodejs
#    nodejs --version

###### Additional settings ##########
RUN echo "lsb_release -a" >> ~/.bashrc

# Japanese
RUN echo "export LANG=C.UTF-8" >> ~/.bashrc
RUN echo "export LANGUAGE=en_US" >> ~/.bashrc

# Change command 'python3' -> 'python'
RUN echo 'export alias python="python3"' >> ~/.bashrc && \
    echo 'export alias pip="pip3"' >> ~/.bashrc

# Changing work directory to workspace
WORKDIR /workspace

# Commands
CMD ["/usr/sbin/sshd", "-D"]
