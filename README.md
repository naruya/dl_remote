# dl_remote

## Usage

```
$ ssh foo@bar -L 5999:localhost:5999 -L 8888:localhost:8888
$ docker run --gpus all -it --net=host --name dl_remote naruya/dl_remote:cuda-11.8

% vnc  # start x11vnc (optional)
% jup  # jupyter lab (optional)

# activate python environment
% source ~/venv/work/bin/activate
% python -c "import torch; print(torch.cuda.is_available())"
```

## Test

### vnc
```
% apt install x11-apps mesa-utils
% vnc  # start x11vnc
% xeyes  # cpu rendering
% glxgears  # gpu rendering
```
