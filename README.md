# Pallium Network
[![Website](https://img.shields.io/badge/website-pallium.network-brightgreen.svg)](http://pallium.network/)
[![Gitter](https://img.shields.io/badge/chat-on%20Discord-green.svg)](https://discord.gg/j7GhMEy)
[![Status](https://img.shields.io/badge/status-POC--1-yellowgreen.svg)](https://discord.gg/j7GhMEy)

Pallium Network is a distributed computing network for machine learning.
Like any other distributed network, Pallium Network possesses an increased computing capacity: big tasks get divided into small ones and at the same time they get processed on a number of units.   Architecture dispersion and the absence of the center in a distributed network increase its fault tolerance and widen scaling features for productivity growth.     
Pallium Network is decentralized and self-organized; it forms an eco-system where all processes and events happen among its participants and get regulated directly by them. Pallium Network decentralization allows to level out improper usage and errors appropriate for networks with centralized administration, and equals the rights of all its participants.    
Pallium Network is capable of finding solutions for tasks of any complexity and scale. The main mission of Pallium Network is to contribute to development of artificial intelligence and machine learning.

## Installation

Install TensorFlow and validate the installation as described on https://www.tensorflow.org/install/.

On OS X TensorFlow could be installed with HomeBrew:
```
brew install tensorflow
```

Install Tendermint v0.22.8 from binary release https://github.com/tendermint/tendermint/releases/tag/v0.22.8-autodraft.

For Linux or OS X just copy the binary to `/usr/local/bin`

Clone Pallium repository, install dependencies and compile application:
```
git clone https://github.com/neocortexlab/pallium.git
cd pallium
mix deps.get
mix compile
```

Initialize tendermint from pallium directory:
```
make tm.init
```

## Running

Run Pallium application:
```
$ iex -S mix
```

After Pallium application started, run tendermint node in another terminal window:
```
make tm.node
```
