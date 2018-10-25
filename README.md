## Installation
[![Gitter](https://img.shields.io/badge/chat-on%20Discord-green.svg)](https://discord.gg/j7GhMEy)
[![Status](https://img.shields.io/badge/status-POC--1-yellowgreen.svg)](https://discord.gg/j7GhMEy)

Install TensorFlow and validate the installation as described on https://www.tensorflow.org/install/.

On OS X TensorFlow could be installed with HomeBrew:
```
brew install tensorflow
```

Install Tendermint v0.22.8 from binary release https://github.com/tendermint/tendermint/releases/tag/v0.22.8-autodraft.

For Linux or OS X just copy the binary to `/usr/local/bin`

Clone Reml repository, install dependencies and compile application:
```
git clone https://github.com/neocortexlab/reml.git
cd reml
mix deps.get
mix compile
```

Initialize tendermint from reml directory:
```
make tm.init
```

## Running

Run Reml application:
```
$ iex -S mix
```

After Reml application started, run tendermint node in another terminal window:
```
make tm.node
```
