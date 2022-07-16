# CUDA 11.0, CUDNN 8.0, Tensorflow, PyTorch, zsh, pyenv, vnc
# See -> https://hub.docker.com/r/naruya/dl_remote

# [1] https://github.com/robbyrussell/oh-my-zsh
# [2] https://github.com/pyenv/pyenv/wiki/common-build-problems
# [3] https://github.com/tensorflow/tensorflow/blob/v2.4.0/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile


# TensorFlow (from [3]) ----------------
ARG UBUNTU_VERSION=18.04

ARG ARCH=
ARG CUDA=11.0
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=8.0.4.30-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=7.1.3-1
ARG LIBNVINFER_MAJOR_VERSION=7

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        libcublas-${CUDA/./-} \
        cuda-nvrtc-${CUDA/./-} \
        libcufft-${CUDA/./-} \
        libcurand-${CUDA/./-} \
        libcusolver-${CUDA/./-} \
        libcusparse-${CUDA/./-} \
        curl \
        libcudnn8=${CUDNN}+cuda${CUDA} \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip

# Install TensorRT if not building for PowerPC
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# bug (4 Aug 2020)
RUN ln -s /usr/local/cuda-11.0/targets/x86_64-linux/lib/libcusolver.so.10 /usr/local/cuda-11.0/targets/x86_64-linux/lib/libcusolver.so.11


# zsh (from [1]) ----------------
RUN apt-get update && apt-get install -y \
    wget git zsh
SHELL ["/bin/zsh", "-c"]
RUN wget http://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN sed -i "s/# DISABLE_AUTO_UPDATE=\"true\"/DISABLE_AUTO_UPDATE=\"true\"/g" ~/.zshrc

# pyenv (from [2]) ----------------
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
RUN curl https://pyenv.run | zsh && \
    echo '' >> /root/.zshrc && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /root/.zshrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /root/.zshrc && \
    echo 'eval "$(pyenv init --path)"' >> /root/.zshrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.zshrc
RUN source /root/.zshrc && \
    pyenv install 3.8.11 && \
    pyenv global 3.8.11 && \
    pip install -U pip

# X window ----------------
RUN apt-get update && apt-get install -y \
    xvfb x11vnc python-opengl icewm
RUN echo 'alias vnc="export DISPLAY=:0; Xvfb :0 -screen 0 1400x900x24 &; x11vnc -display :0 -forever -noxdamage > /dev/null 2>&1 &; icewm-session &"' >> /root/.zshrc

# DL libraries and jupyter ----------------
RUN source /root/.zshrc && \
    pip install setuptools jupyterlab && \
    pip install tensorflow && \
    pip install pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html && \
    echo 'alias jl="jupyter lab --ip 0.0.0.0 --port 8888 --NotebookApp.token='' --allow-root &"' >> /root/.zshrc && \
    echo 'alias tb="tensorboard --host 0.0.0.0 --port 6006 --logdir runs &"' >> /root/.zshrc

# utils ----------------
RUN apt-get update && apt-get install -y \
    vim


RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["zsh"]
