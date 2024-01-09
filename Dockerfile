# Specify Ubuntu Saucy as base image
FROM ubuntu:jammy
LABEL maintainer="jsbjair"

# Arguments
ARG user
ARG UID=1001
ARG GID=1001
ARG DEBIAN_FRONTEND=noninteractive
# Set Environment Variables & Language Environment
ENV LC_ALL en_US.UTF-8
ENV user ${user:-jair}
ENV HOME /home/$user

# Update Base System
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y language-pack-en software-properties-common \
    apt-transport-https \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales

#Configure ppa
RUN add-apt-repository -y ppa:jonathonf/vim \
    && apt-get update

# Install Basic Packages
RUN apt-get install -y wget curl git man unzip \
    tmux zsh vim-gtk3 lynx htop openssh-server mosh sudo \
    cscope xterm dnsutils x11-xserver-utils fonts-inconsolata

# Install packages needed to compile binaries
RUN apt-get install -y build-essential autotools-dev automake pkg-config

# Install peco
RUN cd /opt \
      && wget https://github.com/peco/peco/releases/download/v0.5.11/peco_linux_amd64.tar.gz \
      && tar -xvf peco_linux_amd64.tar.gz \
      && ln -s /opt/peco_linux_amd64/peco /usr/local/bin

# Install docker
RUN cd /opt \
      && wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.6.tgz \
      && tar -xvf docker-24.0.6.tgz \
      && ln -s /opt/docker/docker /usr/local/bin

# Install kubectl
RUN cd /opt \
      && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
      && chmod +x ./kubectl \
      && ln -s /opt/kubectl /usr/local/bin

# Install trans
RUN cd /opt \
      && wget git.io/trans \
      && chmod +x ./trans \
      && ln -s /opt/trans /usr/local/bin

# Install jq
RUN cd /opt \
      && mkdir jq \
      && wget -O ./jq/jq https://github.com/jqlang/jq/releases/download/jq-1.7/jq-linux-amd64 \
      && chmod +x ./jq/jq \
      && ln -s /opt/jq/jq /usr/local/bin

# Install ctags
RUN cd /opt \
    && git clone https://github.com/universal-ctags/ctags.git \
    && cd ctags \
    && ./autogen.sh \
    && ./configure && make && make install

RUN groupadd -g $GID -o $user
# Add user with name "${user}"
RUN useradd -d /home/$user -u $UID -g $GID -m -s /bin/zsh $user \
    && chsh -s /bin/zsh ${user}
# Allow sudo
RUN echo "$user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user

WORKDIR /home/$user
# Add configuration files
ADD ./config/.tmux.conf ./.tmux.conf
ADD ./config/.zshrc ./.zshrc
ADD ./config/.dircolors ./.dircolors

# Install dircolor solarized
ADD ./config/Xserver /opt/Xserver
RUN cp /opt/Xserver/.Xdefaults ./.Xdefaults

# Change current user
RUN chown -R ${user}:${user} /home/$user
USER $user

# Clone oh-my-zsh
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ./.oh-my-zsh

#Configure vim
RUN git clone https://github.com/jsbjair/customvim.git ./.vim \
    && ln -s ./.vim/.vimrc ./.vimrc \
    && cd ./.vim \
    && git submodule update --init --recursive

# Install pip
RUN curl -L https://bootstrap.pypa.io/get-pip.py | python3 \
    && python3 -m pip install -r ./.vim/requirements.txt

# Put peco script
RUN mkdir -p ./.zsh \
    && git clone https://gist.github.com/ad77e50ae4646ae1f46f45a555585974.git ./.zsh/ \
    && echo "source ~/.zsh/peco-select-history.zsh" >> ./.zshrc

CMD ["tmux"]
# Expose ssh port and mosh port
EXPOSE 22 6000
