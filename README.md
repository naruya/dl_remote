# dl_remote

## Usage

```
$ ssh foo@bar -L 5900:localhost:5900 -L 6006:localhost:6006 -L 8888:localhost:8888
$ docker run --gpus all -it --privileged -p 5900:5900 -p 6006:6006 -p 8888:8888 --name dl_remote naruya/dl_remote
% vnc  # start x11vnc
% jl  # jupyter lab
% tb  # tensorboard
```

## Test

### Pytorch
- `python -c "import torch; print(torch.cuda.is_available())"`

### Tensorflow
- `python -c "import tensorflow as tf; print(tf.test.is_gpu_available())"`

### x11vnc

```
% apt install x11-apps mesa-utils
% vnc  # start x11vnc
% xeyes  # cpu rendering
% glxgears  # gpu rendering
```
