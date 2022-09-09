## upgrade-memed-v2.0.5-v2.0.8 for testnet
### Memed v2.0.8 Hard Fork

To resolve the pruning=nothing issue in previous upgrade, we need to perform a hard fork to fix it, here is the steps:

## 

```jsx
Performing the Upgrade
1. Stop the node
sudo systemctl stop memed

2. Backup
cp -r $HOME/.memed $HOME/.memed.bak

3. Purge previous chain state and addrbook.json
memed tendermint unsafe-reset-all --home $HOME/.memed

4. Purge current peers and seeds from config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"\"/" ~/.meme/config/config.toml

5. Add seeds and peers to config.toml
PEERS="44aeb03d0366833b45292708273b001b02e30efe@143.198.102.36:26656,7f0f67a55626b7755c0ef8b8e6b0d4f6c2aea035@45.76.177.106:26656,6ec745dee6d25d28191d3a5ef46d858cbfe60fbd@134.122.18.140:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.memed/config/config.toml`

6 Download and install the new binary
#Install memed v2.0.8
git clone https://github.com/memecosmos/meme.git
cd meme
git checkout v2.0.8
make install

To confirm the correct binary is installed, do:

memed version --long
name: meme
server_name: memed
version: v2.0.8
commit: bb4573ca7e8a31ca52abf6866e2340ed0e288722
build_tags: netgo,ledger
go: go version go1.18.5 linux/amd64

7. [OPTIONAL] If you use cosmovisor
You will need to re-setup cosmovisor with the new genesis.

rm $DAEMON_HOME/cosmovisor/genesis/bin/memed
rm -rf $DAEMON_HOME/cosmovisor/upgrades
mkdir $DAEMON_HOME/cosmovisor/upgrades
cp $HOME/go/bin/memed $DAEMON_HOME/cosmovisor/genesis/bin
rm $DAEMON_HOME/cosmovisor/current

Check memed has copied to the new location.

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

8. Download the  genesis
rm ~/.memed/config/genesis.json
wget 
mv genesis.json $HOME/.memed/config/genesis.json

9. Verify genesis shasum

jq -S -c -M '' ~/.memed/config/genesis.json | sha256sum

# this will return
# 

10. Be paranoid
#This isn't strictly necessary - you can skip it, just double-check.
memed tendermint unsafe-reset-all --home $HOME/.memed

11. Restore priv_validator_key.json and priv_validator_state.json
cp ~/.memed.bak/data/priv_validator_state.json ~/.memed/data/priv_validator_state.json
cp ~/.memed.bak/data/priv_validator_key.json ~/.memed/data/priv_validator_key.json

12. Start the node
sudo systemctl restart memed

13. Confirm the process running
sudo journalctl -fu memed
```
