# https://hub.docker.com/r/naruya/
# 5900: VNC, 8888: jupyter, 6006: tensorboard
# $ docker run --runtime=nvidia -it --privileged -p 5900:5900 -p 8888:8888 -p 6006:6006 naruya/dl_remote

# [1] https://github.com/robbyrussell/oh-my-zsh
# [2] https://github.com/pyenv/pyenv/wiki/common-build-problems
# [3] https://github.com/openai/mujoco-py/blob/master/Dockerfile

FROM nvidia/cudagl:10.1-devel-ubuntu18.04

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
    echo '' >> $HOME/.zshrc && \
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> $HOME/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> $HOME/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.zshrc

ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install 3.7.4 && \
    pyenv global 3.7.4 && \
    pyenv rehash

# X window ----------------
RUN apt-get install -y xvfb x11vnc python-opengl --no-install-recommends

# Python, Jupyter
RUN apt-get update && apt-get install -y ffmpeg nodejs npm
RUN pip install 'setuptools>=41.0.0' && \
    pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html && \
    echo 'alias jl="DISPLAY=:0 jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &"' >> /root/.zshrc && \
    echo 'alias tb="tensorboard --logdir runs --bind_all &"' >> $HOME/.zshrc

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


# MuJoCo 2.0 (for dm_control)
RUN mkdir -p $HOME/.mujoco && \
  wget https://www.roboti.us/download/mujoco200_linux.zip -O mujoco.zip --no-check-certificate && \
  unzip mujoco.zip -d $HOME/.mujoco && \
  rm mujoco.zip && \
  ln -s $HOME/.mujoco/mujoco200_linux $HOME/.mujoco/mujoco200
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$HOME/.mujoco/mujoco200/bin
RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.mujoco/mjpro200/bin' >> $HOME/.zshrc && \
    echo 'export DISPLAY=:0' >> $HOME/.zshrc

# Fixes Segmentation Fault
# See: https://github.com/openai/mujoco-py/pull/145#issuecomment-356938564
ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libGLEW.so

# Set MuJoCo rendering mode (for dm_control)
ENV MUJOCO_GL "glfw"

RUN touch $HOME/.mujoco/mjkey.txt

COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

RUN rm $HOME/.mujoco/mjkey.txt

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh $HOME/
COPY test_mujoco.py $HOME/tests/

WORKDIR $HOME
CMD ["zsh"]
