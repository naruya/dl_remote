# dl_remote (beta)
For Deep Reinforcement Learning on remote server.

# Usage

```shell
$ ssh foo@bar
$ git clone https://github.com/naruya/dl_remote.git
$ cd dl_remote
$ cp /path/to/mjkey.txt ./
$ docker build . -t dl_remote  # it takes about 15 min
$ docker run -it --rm --privileged -p 5900:5900 -p 8888:8888 -p 6006:6006 --name dl_remote dl_remote
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

# Troubleshooting

- Can't install via apt-get
  - run `apt-get update`
