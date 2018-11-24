tm.init:
	rm -rf ~/.tendermint
	tendermint init

tm.node:
	tendermint unsafe_reset_all
	tendermint node --consensus.create_empty_blocks=false

TM_PRIV_VALIDATOR ?= ~/.tendermint/config/priv_validator.json
NODE_ADDRESS = `cat $(TM_PRIV_VALIDATOR) | grep '"address"' | sed 's/"address": "\([^"]*\)",/\1/'`

run:
	elixir --detached --no-halt -S mix run

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

docker.build:
	docker build --build-arg APP_NAME=$(APP_NAME) \
    --build-arg APP_VSN=$(APP_VSN) \
    -t $(APP_NAME):$(APP_VSN)-$(BUILD) \
    -t $(APP_NAME):latest .

docker.clean:
	-docker rm `docker ps -a -q`
	-docker rmi -f `docker images -q`
	-docker network prune -f

docker.tm:
	docker exec -it node$(NODE) /opt/tm/tendermint node

docker.app:
	docker exec -it node$(NODE) /bin/sh start_app.sh
	# docker exec -it node$(NODE) iex --sname $(NODE_ADDRESS) -S mix

docker.sh:
	docker exec -it node$(NODE) /bin/sh

tmux.node:
	tmux new -d -s node$(NODE) 'NODE=$(NODE) make docker.tm; read' \; \
		split-window -h -d 'NODE=$(NODE) make docker.app; read'\; \
		attach

py.console:
	PYTHONPATH=python python

db.start:
	cassandra -f
