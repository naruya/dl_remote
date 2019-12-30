# dl_remote
For Deep Reinforcement Learning on remote server.

# Usage

```shell
$ ssh foo@bar
$ git clone https://github.com/naruya/dl_remote.git
$ cd dl_remote
$ cp /path/to/mjkey.txt ./
$ docker build . -t dl_remote  # it takes about 15 min
$ nvidia-docker run -it --privileged -v /share2/n-kondo/:/root/share -p 5900:5900 -p 8888:8888 -p 6006:6006 --name kondo_temp dl_remote
```

in your container,
```
# ./start.sh
```

use vnc viewer on your local machine

# Test

```shell
$ cd tests
$ python test_mujoco.py
```
