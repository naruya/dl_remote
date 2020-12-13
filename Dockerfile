FROM nvidia/cuda:10.2-devel-ubuntu18.04
ENV DEBIAN_FRONTEND=noninteractive

# zsh ----------------
RUN apt-get update && apt-get install -y \
    wget git zsh
SHELL ["/bin/zsh", "-c"]
RUN wget http://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# pyenv ----------------
RUN apt-get update && apt-get install -y \
    build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
RUN curl https://pyenv.run | zsh && \
    echo 'export PATH="/root/.pyenv/bin:$PATH"' >> /root/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> /root/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.zshrc
RUN source /root/.zshrc && \
    pyenv install 3.8.0 && \
    pyenv global 3.8.0 && \
    pip install -U pip

# X window ----------------
RUN apt-get update && apt-get install -y \
    xvfb x11vnc python-opengl icewm

# utils
RUN source /root/.zshrc && \
    pip install setuptools jupyterlab && \
    pip install torch torchvision && \
    pip install tensorflow && \
    echo 'alias jl="DISPLAY=:0 jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &"' >> /root/.zshrc

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /root/
WORKDIR /root
CMD ["zsh"]

