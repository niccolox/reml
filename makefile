docker.init:
	docker run -it --rm -v "/tmp:/tendermint" tendermint/tendermint init

docker.node:
	docker run -it --rm -v "/tmp:/tendermint" tendermint/tendermint unsafe_reset_all
	docker run -it --rm -v "/tmp:/tendermint" tendermint/tendermint node --consensus.create_empty_blocks=false

tm.init:
	rm -rf ~/.tendermint
	tendermint init

tm.node:
	tendermint unsafe_reset_all
	tendermint node --consensus.create_empty_blocks=false

run:
	elixir --detached --no-halt -S mix run
