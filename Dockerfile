# Specify Ubuntu Saucy as base image
FROM ubuntu:xenial
LABEL maintainer="jsbjair"

# Arguments
ARG user
ARG UID=1001
ARG GID=1001
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
    && add-apt-repository -y ppa:ondrej/php \
    && add-apt-repository -y ppa:zeal-developers/ppa \
    && apt-get update

# Install Basic Packages
RUN apt-get install -y wget curl git man unzip \
    tmux zsh php vim-gtk3 lynx htop openssh-server mosh sudo

# Install packages needed to compile binaries
RUN apt-get install -y build-essential autotools-dev automake pkg-config

# Install peco
RUN cd /opt \
      && wget https://github.com/peco/peco/releases/download/v0.5.3/peco_linux_amd64.tar.gz \
      && tar xvf peco_linux_amd64.tar.gz \
      && ln -s /opt/peco_linux_amd64/peco /usr/local/bin

# Install jq
RUN cd /opt \
      && mkdir jq \
      && wget -O ./jq/jq http://stedolan.github.io/jq/download/linux64/jq \
      && chmod +x ./jq/jq \
      && ln -s /opt/jq/jq /usr/local/bin

# Install ctags
RUN cd /opt \
    && wget http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz \
    && tar -xzf ctags-5.8.tar.gz \
    && cd ctags-5.8 \
    && ./configure && make && make install

# Install composer.phar
RUN cd /opt \
    && wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet \
    && ln -sf /opt/composer.phar /usr/local/bin/composer

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
    && echo "source ./.zsh/peco-select-history.zsh" >> ./.zshrc

CMD ["tmux"]
# Expose ssh port and mosh port
EXPOSE 22 6000
