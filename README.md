# dl_remote

## Usage

```
$ ssh foo@bar -L 5900:localhost:5900 -L 8888:localhost:8888
$ docker run --gpus all -it -p 5900:5900 -p 8888:8888 --name dl_remote naruya/dl_remote:cuda-11.8

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
