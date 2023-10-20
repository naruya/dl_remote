FROM nvidia/cuda:11.8.0-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive


# zsh
RUN apt-get update && apt-get install -y wget git zsh
SHELL ["/bin/zsh", "-c"]
RUN wget http://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN sed -i "s/# zstyle ':omz:update' mode disabled/zstyle ':omz:update' mode disabled/g" ~/.zshrc

# python (latest version)
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3.9 python3.9-dev python3.9-venv python3-pip
RUN ln -s /usr/bin/python3.9 /usr/bin/python

# vnc
RUN apt-get update && apt-get install -y xvfb x11vnc icewm lsof
RUN echo 'alias vnc="export DISPLAY=:99; Xvfb :99 -screen 0 1400x900x24 & until xdpyinfo > /dev/null 2>&1; do sleep 0.1; done; x11vnc -display :99 -forever -noxdamage -rfbport 5900 > /dev/null 2>&1 & until lsof -i :5900 > /dev/null; do sleep 0.1; done; icewm-session &"' >> /root/.zshrc

# venv
RUN python -m venv /root/venv/work
RUN source /root/venv/work/bin/activate && \
    pip install -U pip setuptools && \
    pip install torch==2.0.0+cu118 torchvision==0.15.1+cu118 torchaudio==2.0.1 --extra-index-url https://download.pytorch.org/whl/cu118

# utils
RUN apt-get update && apt-get install -y htop vim ffmpeg
RUN source /root/venv/work/bin/activate && \
    pip install jupyterlab ipywidgets && \
    echo 'alias jup="jupyter lab --ip 0.0.0.0 --port 8888 --NotebookApp.token='' --allow-root &"' >> /root/.zshrc

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["zsh"]
