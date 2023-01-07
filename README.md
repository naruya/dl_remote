# dl_remote

## Usage

```
$ ssh foo@bar -L 5900:localhost:5900 -L 6006:localhost:6006 -L 8888:localhost:8888
$ docker run --gpus all -it --privileged -p 5900:5900 -p 6006:6006 -p 8888:8888 --name dl_remote naruya/dl_remote

% vnc  # start x11vnc
% jl  # jupyter lab
% tb  # tensorboard

% pyenv virtualenv 3.8.13 work
% pyenv local work
% pip install -U pip
% pip install setuptools

# tensorflow
% pip install tensorflow

# pytorch
% pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117
```

## Test

### Pytorch
- `python -c "import torch; print(torch.cuda.device_count())"`

### Tensorflow
- `python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"`

### x11vnc

```
% apt install x11-apps mesa-utils
% vnc  # start x11vnc
% xeyes  # cpu rendering
% glxgears  # gpu rendering
```
