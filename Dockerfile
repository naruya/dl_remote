# https://hub.docker.com/r/naruya/
# 5900: VNC, 8888: jupyter, 6006: tensorboard
# $ docker run --runtime=nvidia -it --privileged -p 5900:5900 -p 8888:8888 -p 6006:6006 naruya/dl_remote

# [1] https://github.com/robbyrussell/oh-my-zsh
# [2] https://github.com/pyenv/pyenv/wiki/common-build-problems
# [3] https://github.com/openai/mujoco-py/blob/master/Dockerfile

FROM nvidia/cudagl:10.2-devel-ubuntu18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root

# zsh,[1] ----------------
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y \
    wget \
    curl \
    git \
    vim \
    zsh \
    unzip --no-install-recommends

SHELL ["/bin/zsh", "-c"]
RUN wget http://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# pyenv,[2] ----------------
RUN apt-get update && \
    apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl --no-install-recommends

RUN curl https://pyenv.run | zsh && \
    echo '' >> /root/.zshrc && \
    echo 'export PATH="/root/.pyenv/bin:$PATH"' >> /root/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> /root/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.zshrc

ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install 3.7.4 && \
    pyenv global 3.7.4 && \
    pyenv rehash

# X window ----------------
RUN apt-get install -y xvfb x11vnc python-opengl --no-install-recommends

# Python, Jupyter
RUN apt-get update && apt-get install -y ffmpeg nodejs npm
RUN pip install setuptools && \
    pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html && \
    echo 'alias jl="DISPLAY=:0 jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &"' >> /root/.zshrc && \
    echo 'alias tb="tensorboard --logdir runs --bind_all &"' >> /root/.zshrc

# window manager
RUN apt-get update && apt-get install -y icewm

# MuJoCo150,[3]  # TODO
RUN apt-get install -y \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libosmesa6-dev \
    software-properties-common \
    net-tools \
    virtualenv \
    xpra \
    xserver-xorg-dev \
    libglfw3 --no-install-recommends

RUN curl -o /usr/local/bin/patchelf https://s3-us-west-2.amazonaws.com/openai-sci-artifacts/manual-builds/patchelf_0.9_amd64.elf \
    && chmod +x /usr/local/bin/patchelf

RUN mkdir -p /root/.mujoco && \
    wget https://www.roboti.us/download/mjpro150_linux.zip -O mujoco.zip && \
    unzip mujoco.zip -d /root/.mujoco && \
    rm mujoco.zip
RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mjpro150/bin' >> /root/.zshrc && \
    echo 'export DISPLAY=:0' >> /root/.zshrc
COPY mjkey.txt /root/.mujoco/

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mjpro150/bin
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /root/
COPY test_mujoco.py /root/tests/

WORKDIR /root
CMD ["zsh"]
