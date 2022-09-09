#!/usr/bin/env bash
set -x
export DISPLAY=:0.0

echo
echo "== Meme testnet installer =="
echo

secs=$((5 * 1))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done



### MEME TESTNET INSTALLER -- Flash | Meme

RPC1="https://rpc-testnet-1.meme.sx:443"
RPC2="http://143.198.102.36:26657"
RPC3="http://128.199.197.228:26657"

service memed-testnet stop

backup priv_validator_key.json 
cp ~/.memed/config/priv_validator_key.json ~/


rm -r ~/.go -rf
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.18.5
source ~/.bashrc

cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version


git clone https://github.com/MEMECosmos/meme
cd meme
git checkout v2.0.8
make install


#reset chain data
memed tendermint unsafe-reset-all  --home /root/.memed

memed config chain-id meme-testnet-2
memed config keyring-backend test
memed config output json

# setup chain
INIT=$(memed init testnet --chain-id meme-testnet-2)

config="$HOME/.memed/config/config.toml"
genesis="$HOME/.memed/config/genesis.json"
app="$HOME/.memed/config/app.toml"



curl -# https://raw.githubusercontent.com/memecosmos/testnet/main/meme-testnet-2/genesis.json -o $genesis

sed -i -E 's/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.025umeme\"/g' $app

PEERS="cfd6bbf0f73fc6bebe77186fe074eaee313b9e69@143.198.102.36:26656,964a2d95dc93d6493c51ecd80ed3acc444839b9e@45.76.177.106:26656,decd5a2f00260c65c43b531cb9b0b8e542419f4c@134.122.18.140:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.memed/config/config.toml


LATEST_HEIGHT=$(curl -s $RPC1/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$RPC1/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)


sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$RPC1,$RPC2,$RPC3\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $config


sed -i -E 's/pruning = \"default\"/pruning = \"everything\"/g' $app



if [ "$(uname)" = "Linux" ]; then
tee /etc/systemd/system/memed-testnet.service > /dev/null <<EOF
[Unit]
Description=MEME local Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$GOBIN/memed start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

cp ~/priv_validator_key.json ~/.memed/config/priv_validator_key.json

systemctl enable memed-testnet --now

echo "service memed-testnet status"
service memed-testnet status

sleep 5

echo
echo
echo "Meme testnet service started. Please wait 5 to 10 mins for state-sync."
echo
echo "You can type 'curl -s 127.0.0.1:26657/abci_info | jq .' to check block status."
echo "Check log type: 'tail -f /var/log/syslog' "
echo "Catching check type: 'memed status 2>&1 | jq \"{catching_up: .SyncInfo.catching_up}\" '"
echo
echo "Faucet : https://testnet-faucet.meme.sx/"
echo 
echo 

curl -s 127.0.0.1:26657/abci_info | jq .
echo
echo
memed status 2>&1 | jq "{catching_up: .SyncInfo.catching_up}"
echo
echo
echo "For Meme testnet installer tools for development team"
echo "Flash | Meme @ 2022 09"


