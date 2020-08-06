# Specify Ubuntu Saucy as base image
FROM ubuntu:bionic
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
    cscope

# Install packages needed to compile binaries
RUN apt-get install -y build-essential autotools-dev automake pkg-config

# Install peco
RUN cd /opt \
      && wget https://github.com/peco/peco/releases/download/v0.5.7/peco_linux_amd64.tar.gz \
      && tar -xvf peco_linux_amd64.tar.gz \
      && ln -s /opt/peco_linux_amd64/peco /usr/local/bin

# Install docker
RUN cd /opt \
      && wget https://download.docker.com/linux/static/stable/x86_64/docker-19.03.8.tgz \
      && tar -xvf docker-19.03.8.tgz \
      && ln -s /opt/docker/docker /usr/local/bin

# Install docker-compose
RUN cd /opt \
      && wget "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -O docker/docker-compose \
      && chmod +x ./docker/docker-compose \
      && ln -s /opt/docker/docker-compose /usr/local/bin

# Install trans
RUN cd /opt \
      && wget git.io/trans \
      && chmod +x ./trans \
      && ln -s /opt/trans /usr/local/bin

# Install jq
RUN cd /opt \
      && mkdir jq \
      && wget -O ./jq/jq http://stedolan.github.io/jq/download/linux64/jq \
      && chmod +x ./jq/jq \
      && ln -s /opt/jq/jq /usr/local/bin

# Install ctags
RUN cd /opt \
    && git clone https://github.com/universal-ctags/ctags.git \
    && cd ctags \
    && ./autogen.sh \
    && ./configure && make && make install

# Install dircolor solarized
RUN mkdir /opt/dev-env-config \
    && cd /opt/dev-env-config \
    && wget -O .dircolors https://raw.github.com/seebi/dircolors-solarized/master/dircolors.256dark

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
# Change current user
RUN chown -R ${user}:${user} /home/$user
USER $user

# Clone oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ./.oh-my-zsh

#Configure vim
RUN git clone https://github.com/jsbjair/customvim.git ./.vim \
    && ln -s ./.vim/.vimrc ./.vimrc \
    && cd ./.vim \
    && git submodule update --init --recursive

# Put peco script
RUN mkdir -p ./.zsh \
    && git clone https://gist.github.com/ad77e50ae4646ae1f46f45a555585974.git ./.zsh/ \
    && echo "source ~/.zsh/peco-select-history.zsh" >> ./.zshrc

CMD ["tmux"]
# Expose ssh port and mosh port
EXPOSE 22 6000
