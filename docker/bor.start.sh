#!/usr/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -e

BOR_DIR=${BOR_DIR:-~/bor_data} # data folder of bor
DATA_DIR=$BOR_DIR/data
HEIMDALL_ADDRESS=${HEIMDALL_ADDRESS:-"polygon-heimdall"}

init() {
    if [ -f $HOME/bor_data/initialized ]; then
        return 0
    fi
    mkdir -p $HOME/bor_data
    mkdir -p $HOME/bor_data/data
    wget https://raw.githubusercontent.com/maticnetwork/launch/master/mainnet-v1/sentry/sentry/bor/genesis.json
    cp -rf genesis.json $HOME/bor_data/gensis.json
    bor --datadir $HOME/bor_data/data init genesis.json
    wget -c https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mumbai/bor-fullnode-node-snapshot-2022-01-17.tar.gz -O - | tar -xz -C $HOME/bor_data/data
    touch $HOME/bor_data/initialized
}

start() {
    bor --datadir $DATA_DIR \
        --port 30303 \
        --http --http.addr '0.0.0.0' \
        --http.vhosts '*' \
        --http.corsdomain '*' \
        --http.port 8545 \
        --ws --ws.addr '0.0.0.0' \
        --ws.port 8546 \
        --ipcpath $DATA_DIR/bor.ipc \
        --http.api 'debug,eth,net,web3,txpool,bor' \
        --ws.api 'debug,eth,net,web3,txpool,bor' \
        --syncmode 'fast' \
        --bor.heimdall="http://${HEIMDALL_ADDRESS}:1317" \
        --gcmode 'full' \
        --networkid '80001' \
        --miner.gaslimit '200000000' \
        --miner.gastarget '20000000' \
        --txpool.nolocals \
        --txpool.accountslots '128' \
        --txpool.globalslots '20000' \
        --txpool.lifetime '0h16m0s' \
        --maxpeers 200 \
        --metrics \
        --snapshot="false" \
        --bootnodes "enode://320553cda00dfc003f499a3ce9598029f364fbb3ed1222fdc20a94d97dcc4d8ba0cd0bfa996579dcc6d17a534741fb0a5da303a90579431259150de66b597251@54.147.31.250:30303,enode://f0f48a8781629f95ff02606081e6e43e4aebd503f3d07fc931fad7dd5ca1ba52bd849a6f6c3be0e375cf13c9ae04d859c4a9ae3546dc8ed4f10aa5dbb47d4998@34.226.134.117:30303"
}

default() {
    echo "{}"
}

wait() {
    while true; do
        sleep 1
        catching_up=$((curl http://$HEIMDALL_ADDRESS:26657/status || default) | jq -r '.result.sync_info.catching_up')
        echo "wait for catching_up: $catching_up";
        if [ "$catching_up" == "false" ]; then
            break
        fi
    done
}

init

wait

start
