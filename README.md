# dl_remote

## Usage

```
$ ssh foo@bar -L 5900:localhost:5900 -L 6006:localhost:6006 -L 8888:localhost:8888
$ docker run --gpus all -it --privileged -p 5900:5900 -p 6006:6006 -p 8888:8888 --name dl_remote naruya/dl_remote:tensorflow

% source ~/venv/work/bin/activate
% pip install ~~~~
% python ~~~~.py

% vnc  # start x11vnc
% jup  # jupyter lab
```

## Test

### Pytorch
- `python -c "import torch; print(torch.cuda.device_count())"`

### Tensorflow
- `python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"`

```tf_mnist.py
# tf_mnist.py

import tensorflow as tf
mnist = tf.keras.datasets.mnist

(x_train, y_train),(x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test, y_test)
```

- `python tf_mnist.py`

### x11vnc

```
% apt install x11-apps mesa-utils
% vnc  # start x11vnc
% xeyes  # cpu rendering
% glxgears  # gpu rendering
```
