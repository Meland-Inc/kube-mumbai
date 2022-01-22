#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -e

init() {
    if [ ! -f "$HOME/heimdall_data/initialized" ]; then
        mkdir -p $HOME/heimdall_data
        heimdalld init --home $HOME/heimdall_data
        wget https://raw.githubusercontent.com/maticnetwork/launch/master/testnet-v4/sentry/sentry/heimdall/config/genesis.json
        cp -rf genesis.json $HOME/heimdall_data/config/genesis.json
        # edit $HOME/heimdall_data/config/config.toml
        sed -i '/moniker/c\moniker = "MelandPolygonTestnetworkNode"' $HOME/heimdall_data/config/config.toml
        sed -i '/seeds/c\seeds = "4cd60c1d76e44b05f7dfd8bab3f447b119e87042@54.147.31.250:26656,b18bbe1f3d8576f4b73d9b18976e71c65e839149@34.226.134.117:26656"' $HOME/heimdall_data/config/config.toml
        sed -i 's/127.0.0.1/0.0.0.0/g' $HOME/heimdall_data/config/config.toml
        wget -c https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mumbai/heimdall-snapshot-2022-01-17.tar.gz -O - | tar -xz -C $HOME/heimdall_data/data
        touch $HOME/heimdall_data/initialized
    fi
}

init

echo "start heimdall";

nohup heimdalld start --home=/root/heimdall_data &

echo "start rest-server";

heimdalld rest-server --home $HOME/heimdall_data --chain-id=137
