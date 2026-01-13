FROM nvidia/cuda:12.6.3-devel-ubuntu24.04
ENV DEBIAN_FRONTEND=noninteractive


# zsh
RUN apt-get update && apt-get install -y wget git zsh
SHELL ["/bin/zsh", "-c"]
RUN wget http://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN sed -i "s/# zstyle ':omz:update' mode disabled/zstyle ':omz:update' mode disabled/g" ~/.zshrc

# python
RUN apt-get update && apt-get install -y python3.12 python3.12-dev python3.12-venv python3-pip
RUN ln -s /usr/bin/python3.12 /usr/bin/python

# utils
RUN apt-get update && apt-get install -y htop vim ffmpeg


RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["zsh"]
