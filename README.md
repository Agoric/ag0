# Agoric Phase 0

TL;DR: Compile using Golang 1.17 with `make build`, and run `build/ag0`.

Phase 0 of the [Agoric blockchain's](https://agoric.com/) mainnet will not have
the [Agoric SDK](https://github.com/Agoric/agoric-sdk) enabled until governance
votes to turn it on.  Until then, validators run `ag0` to bootstrap the
chain with support for Cosmos-layer validation, staking, and governance.


### Installation


#### Requirements Installation
Update current and install required packages:

```bash
# Install Git
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential make gcc git jq -y
```


Install Go:

```bash
wget https://golang.org/dl/go1.17.7.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz
```
And add Go to your path by adding these commands in ~/.bashrc or ~/.profile:

```bash
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
```

Don't forget to source your .bashrc `source ~/.bashrc`

#### Build Agoric

Download the Agoric source, checkout the latest version, and install:

```bash
git clone https://github.com/Agoric/ag0.git
cd ag0
git fetch
git checkout agoric-upgrade-5

make install
```

#### Download the Genesis file

Update the genesis file:

```bash
wget https://main.agoric.net/genesis.json
mv ./genesis.json $HOME/.agoric/config/genesis.json
```

#### Configuration Setup

An updated list of seeds/peers can be found here: https://main.agoric.net/network-config. Then edit the `~/.agoric/config/config.toml` file:

```bash
persistent_peers = "a26158a5cbb1df581dd6843ac427191af76d6d5d@104.154.240.50:26656,6e26a1b4afa6889f841d7957e8c2b5d50d32d485@95.216.53.26:26656"
```


#### Cosmovisor Installation

```bash
go get github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor
```

`which cosmovisor` should return `/home/${USER}/go/bin/cosmovisor`

Set up the folder structure and add the binary to cosmovisor:

```bash
mkdir -p $HOME/.agoric/cosmovisor/genesis/bin
mkdir -p $HOME/.agoric/cosmovisor/upgrades

cp $HOME/go/bin/ag0 $HOME/.agoric/cosmovisor/genesis/bin
```

Set up service
Commands sent to Cosmovisor are sent to the underlying binary. For example, `cosmovisor version` is the same as typing `ag0 version`.
Nevertheless, just as we would manage junod using a process manager, we would like to make sure Cosmovisor is automatically restarted if something happens, for example an error or reboot.

```bash
sudo nano /etc/systemd/system/cosmovisor.service
```
```bash
[Unit]
Description=cosmovisor
After=network-online.target

[Service]
User=ubuntu
ExecStart=/home/ubuntu/go/bin/cosmovisor start
Restart=always
RestartSec=10
LimitNOFILE=4096
Environment="DAEMON_NAME=ag0"
Environment="DAEMON_HOME=/home/ubuntu/.agoric"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_LOG_BUFFER_SIZE=512"

[Install]
WantedBy=multi-user.target
```

Enable the cosmovisor service:

```bash
sudo -S systemctl daemon-reload
sudo -S systemctl enable cosmovisor
```

#### Useful Commands


Start Cosmovisor
```bash
sudo systemctl start cosmovisor
```

Stop Cosmovisor
```bash
sudo systemctl stop cosmovisor
```

Check Cosmovisor's logs
```bash
journalctl -u cosmovisor.service -f
```

Check the node's sync status
```bash
curl localhost:26657/status
```

