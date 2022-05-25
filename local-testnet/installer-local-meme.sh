#!/usr/bin/env bash
# set -x
export DISPLAY=:0.0

### MEME LOCAL INSTALLER -- Flash | Meme


service memed stop

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

memed config chain-id meme-local-1
memed config keyring-backend test
memed config output json
MEME_a=$(yes | memed keys add meme)
DEV_a=$(yes | memed keys add dev)
FAUCET_a=$(yes | memed keys add faucet)
TEST_a=$(yes | memed keys add test)
TEST2_a=$(yes | memed keys add test2)
MEME=$(memed keys show meme -a)
DEV=$(memed keys show dev -a)
FAUCET=$(memed keys show faucet -a)
TEST=$(memed keys show test -a)
TEST2=$(memed keys show test2 -a)


# setup chain
memed init meme --chain-id meme-local-1

config="$HOME/.memed/config/config.toml"
genesis="$HOME/.memed/config/genesis.json"
app="$HOME/.memed/config/app.toml"

if [ "$(uname)" = "Linux" ]; then
  sed -i "s/cors_allowed_origins = \[\]/cors_allowed_origins = [\"*\"]/g" $config
  sed -i -e 's/"stake"/"umeme"/g' $genesis;
  sed -i '/\[api\]/,+3 s/enable = false/enable = true/' $app
else
  sed -i '' "s/cors_allowed_origins = \[\]/cors_allowed_origins = [\"*\"]/g" $config
  sed -i '' -e 's/"stake"/"umeme"/g' $genesis;
  sed -i '' '/\[api\]/,+3 s/enable = false/enable = true/' $app
fi


memed add-genesis-account $TEST 10000000000000000umeme
memed add-genesis-account $MEME 10000000000000000umeme
memed add-genesis-account $DEV 10000000000000000umeme
memed add-genesis-account $TEST2 10000000000000000umeme
memed add-genesis-account $FAUCET 10000000000000000umeme

memed gentx meme 20000000000umeme --chain-id meme-local-1 --keyring-backend test
memed collect-gentxs
memed validate-genesis



if [ "$(uname)" = "Linux" ]; then
tee /etc/systemd/system/memed.service > /dev/null <<EOF
[Unit]
Description=MEME local Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$GOBIN/memed start
Restart=always
RestartSec=3
LimitNOFILE=65535
StandardOutput=file:/var/log/memed.log
StandardError=file:/var/log/memed.log

[Install]
WantedBy=multi-user.target
EOF


systemctl enable memed --now

echo "service memed status"
service memed status

else

memed unsafe-reset-all
memed start

fi


echo
echo "Please copy the mnemonic of the test account for development."
echo
echo $MEME_a | jq '{name: .name, address: .address, mnemonic: .mnemonic}'
echo $DEV_a | jq '{name: .name, address: .address, mnemonic: .mnemonic}'
echo $FAUCET_a | jq '{name: .name, address: .address, mnemonic: .mnemonic}'
echo $TEST_a | jq '{name: .name, address: .address, mnemonic: .mnemonic}'
echo $TEST2_a | jq '{name: .name, address: .address, mnemonic: .mnemonic}'

echo
echo "Meme chain starting"
echo

secs=$((5 * 1))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

echo
echo "You can type 'curl -s 127.0.0.1:26657/abci_info | jq .' to check block status."
echo

curl -s 127.0.0.1:26657/abci_info | jq .

## For Meme development team local installer tools
## Flash | Meme @ 2022 05
