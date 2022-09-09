### 1. Stop the node
```sh
sudo systemctl stop memed
```
### 2. Backup
```sh
cp -r $HOME/.memed $HOME/.memed.bak
```
### 3. Purge previous chain state and addrbook.json
```sh
memed tendermint unsafe-reset-all --home $HOME/.memed
```
### 4. Purge current peers from config.toml
```sh
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"\"/" ~/.memed/config/config.toml
```
### 5. Add peers to config.toml
```sh
PEERS="cfd6bbf0f73fc6bebe77186fe074eaee313b9e69@143.198.102.36:26656,964a2d95dc93d6493c51ecd80ed3acc444839b9e@45.76.177.106:26656,decd5a2f00260c65c43b531cb9b0b8e542419f4c@134.122.18.140:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.memed/config/config.toml
```

### 6. upgrade go to 1.18.5
```sh
rm -r ~/.go -rf
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.18.5
source ~/.bashrc
```

### 7. Download and install the new binary
#Install memed v2.0.8
```sh
git clone https://github.com/memecosmos/meme.git
cd meme
git checkout v2.0.8
make install
```
To confirm the correct binary is installed, do:
```sh
memed version --long
```
```sh
name: meme
server_name: memed
version: v2.0.8
commit: bb4573ca7e8a31ca52abf6866e2340ed0e288722
build_tags: netgo,ledger
go: go version go1.18.5 linux/amd64
```
### 8. [OPTIONAL] If you use cosmovisor
You will need to re-setup cosmovisor with the new genesis.
```sh
rm $DAEMON_HOME/cosmovisor/genesis/bin/memed
rm -rf $DAEMON_HOME/cosmovisor/upgrades
mkdir $DAEMON_HOME/cosmovisor/upgrades
cp $HOME/go/bin/memed $DAEMON_HOME/cosmovisor/genesis/bin
rm $DAEMON_HOME/cosmovisor/current
```
Check memed has copied to the new location.
```sh
$DAEMON_HOME/cosmovisor/genesis/bin/memed version

# returns
v2.0.8

tree $DAEMON_HOME/cosmovisor

# returns
/root/.memed/cosmovisor
├── genesis
│   └── bin
│       └── memed
└── upgrades
```

### 9. Download the  genesis
```sh
rm ~/.memed/config/genesis.json
wget https://github.com/memecosmos/testnet/raw/main/meme-testnet-2/meme-testnet-2-genesis.tar.gz
tar -zxvf meme-testnet-2-genesis.tar.gz
mv genesis.json ~/.memed/config/genesis.json
```

### 10. Verify genesis shasum
```sh
jq -S -c -M '' ~/.memed/config/genesis.json | sha256sum

# this will return
# 57964f8190a18a9a37fe96e5ae4b3c64a883825200a1172d3869db03403c8826
```
### 11. Be paranoid
#This isn't strictly necessary - you can skip it, just double-check.
```sh
memed tendermint unsafe-reset-all --home $HOME/.memed
```
### 12. Restore priv_validator_key.json and priv_validator_state.json
```sh
cp ~/.memed.bak/config/priv_validator_key.json ~/.memed/config/priv_validator_key.json
```
### 13. Start the node
```sh
sudo systemctl restart memed
```
### 14. Confirm the process running
```sh
sudo journalctl -fu memed
```
