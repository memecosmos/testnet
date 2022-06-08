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

#Check Golang
if ! [ -x "$(command -v go)" ]; then

wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.17.8
source ~/.bashrc

cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile
go version

fi

#Check Memed
if ! [ -x "$(command -v memed)" ]; then

git clone https://github.com/MEMECosmos/meme
cd meme
git checkout main
make install

fi

#reset chain data
rm -rf $HOME/.memed

memed config chain-id meme-testnet-1
memed config keyring-backend test
memed config output json

# setup chain
INIT=$(memed init testnet --chain-id meme-testnet-1)

config="$HOME/.memed/config/config.toml"
genesis="$HOME/.memed/config/genesis.json"
app="$HOME/.memed/config/app.toml"



curl -# https://raw.githubusercontent.com/memecosmos/testnet/main/meme-testnet-1/genesis.json -o $genesis

sed -i -E 's/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.025umeme\"/g' $app
export PEERS="44aeb03d0366833b45292708273b001b02e30efe@143.198.102.36:26656,7f0f67a55626b7755c0ef8b8e6b0d4f6c2aea035@45.76.177.106:26656,30ded503947be80f44cb3aa82ea9033fcedc9479@128.199.197.228:26656"

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $config


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


systemctl enable memed-testnet --now

echo "service memed-testnet status"
#service memed-testnet status

else

memed unsafe-reset-all
memed start

fi

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
echo "Flash | Meme @ 2022 06"


