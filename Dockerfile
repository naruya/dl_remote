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
RUN apt-get update && apt-get install -y xvfb x11vnc icewm lsof net-tools
RUN echo "alias vnc='PASSWORD=\$(openssl rand -hex 24); for i in {99..0}; do export DISPLAY=:\$i; if ! xdpyinfo &>/dev/null; then break; fi; done; for i in {5999..5900}; do if ! netstat -tuln | grep -q \":\$i \"; then PORT=\$i; break; fi; done; Xvfb \$DISPLAY -screen 0 1400x900x24 & until xdpyinfo > /dev/null 2>&1; do sleep 0.1; done; x11vnc -forever -noxdamage -display \$DISPLAY -rfbport \$PORT -passwd \$PASSWORD > /dev/null 2>&1 & until lsof -i :\$PORT > /dev/null; do sleep 0.1; done; icewm-session &; echo DISPLAY=\$DISPLAY, PORT=\$PORT, PASSWORD=\$PASSWORD'" >> ~/.zshrc

# venv
RUN python -m venv /root/venv/work
RUN source /root/venv/work/bin/activate && \
    pip install -U pip setuptools && \
    pip install torch==2.0.0+cu118 torchvision==0.15.1+cu118 torchaudio==2.0.1 --extra-index-url https://download.pytorch.org/whl/cu118 && \
    echo 'source /root/venv/work/bin/activate' >> /root/.zshrc

# utils
RUN apt-get update && apt-get install -y htop vim ffmpeg
RUN source /root/venv/work/bin/activate && \
    pip install jupyterlab ipywidgets && \
    echo 'alias jup="jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &"' >> /root/.zshrc

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["zsh"]
