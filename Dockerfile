# CUDA 11.2, CUDNN 8.1, Tensorflow, PyTorch, zsh, pyenv, vnc
# See -> https://hub.docker.com/r/naruya/dl_remote

# [1] https://github.com/tensorflow/tensorflow/blob/7b24f3fe24e42cd7dccc085a467b594bb78a0adc/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile


# TensorFlow (from [1]) ----------------
ARG UBUNTU_VERSION=20.04

ARG ARCH=
ARG CUDA=11.8
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}.0-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=8.6.0.163-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=8.4.3-1
ARG LIBNVINFER_MAJOR_VERSION=8

# Let us install tzdata painlessly
ENV DEBIAN_FRONTEND=noninteractive

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-cudart-dev-${CUDA/./-} \
        cuda-nvcc-${CUDA/./-} \
        cuda-cupti-${CUDA/./-} \
        cuda-nvprune-${CUDA/./-} \
        cuda-libraries-${CUDA/./-} \
        cuda-command-line-tools-${CUDA/./-} \
        libcublas-${CUDA/./-} \
        cuda-nvrtc-${CUDA/./-} \
        libcufft-${CUDA/./-} \
        libcurand-${CUDA/./-} \
        libcusolver-${CUDA/./-} \
        libcusparse-${CUDA/./-} \
        curl \
        libcudnn8=${CUDNN}+cuda${CUDA} \
        pkg-config \
        software-properties-common \
        unzip

# Install TensorRT if not building for PowerPC
# NOTE: libnvinfer uses cuda11.6 versions
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64/7fa2af80.pub && \
        echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /"  > /etc/apt/sources.list.d/tensorRT.list && \
        apt-get update && \
        apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.6 \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda11.6 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda-11.8/targets/x86_64-linux/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig


# zsh
RUN apt-get update && apt-get install -y wget git zsh
SHELL ["/bin/zsh", "-c"]
RUN wget http://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
RUN sed -i "s/# zstyle ':omz:update' mode disabled/zstyle ':omz:update' mode disabled/g" ~/.zshrc


# python (latest version)
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3.8 python3.8-dev python3.8-venv python3-pip
RUN ln -s /usr/bin/python3.8 /usr/bin/python


# vnc
RUN apt-get update && apt-get install -y xvfb x11vnc icewm lsof net-tools
RUN echo "alias vnc='PASSWORD=\$(openssl rand -hex 24); for i in {99..0}; do export DISPLAY=:\$i; if ! xdpyinfo &>/dev/null; then break; fi; done; for i in {5999..5900}; do if ! netstat -tuln | grep -q \":\$i \"; then PORT=\$i; break; fi; done; Xvfb \$DISPLAY -screen 0 1400x900x24 & until xdpyinfo > /dev/null 2>&1; do sleep 0.1; done; x11vnc -forever -noxdamage -display \$DISPLAY -rfbport \$PORT -passwd \$PASSWORD > /dev/null 2>&1 & until lsof -i :\$PORT > /dev/null; do sleep 0.1; done; icewm-session &; echo DISPLAY=\$DISPLAY, PORT=\$PORT, PASSWORD=\$PASSWORD'" >> ~/.zshrc


# venv
RUN python -m venv /root/venv/work
RUN source /root/venv/work/bin/activate && \
    pip install -U pip setuptools && \
    pip install tensorflow && \
    echo 'source /root/venv/work/bin/activate' >> /root/.zshrc


# utils
RUN apt-get update && apt-get install -y htop vim ffmpeg
RUN source /root/venv/work/bin/activate && \
    pip install jupyterlab ipywidgets && \
    echo 'alias jup="jupyter lab --ip 0.0.0.0 --port 8888 --allow-root &"' >> /root/.zshrc


RUN apt-get clean && rm -rf /var/lib/apt/lists/*


WORKDIR /root
CMD ["zsh"]
