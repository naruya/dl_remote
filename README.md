# dl_remote

# Usage

```
$ ssh foo@bar -L 8888:localhost:38888 -L 5900:localhost:35900
$ docker run --gpus all -it --privileged -p 38888:8888 -p 35900:5900 --name dl_remote naruya/dl_remote
```

## docker build

```
$ git clone https://github.com/naruya/dl_remote.git
$ cd dl_remote
$ docker build . -t dl_remote
```

in your container,
```
# ./start.sh
```
