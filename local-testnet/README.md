
## easy installer for Meme network dapp developer

Run the following command in a terminal and you’re ready to go!

```
curl -sSL https://raw.githubusercontent.com/memecosmos/testnet/main/local-testnet/installer-local-meme.sh | bash
```



### Cosmwasm for Meme network

```

RPC="tcp://127.0.0.1:26657"

ls -lh target/wasm32-unknown-unknown/release/cw_meme_dapp.wasm
docker run --rm -v "$(pwd)":/code \
  --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
  --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
  cosmwasm/rust-optimizer:0.12.3

ls -alh artifacts/cw_meme_dapp.wasm

RES=$(memed tx wasm store artifacts/cw_meme_dapp.wasm --from meme --node $RPC \
--chain-id meme-local-1 --gas auto --gas-adjustment 1.3 --keyring-backend test -b block)

TX=$(memed tx wasm store cartifacts/cw_meme_dapp.wasmw_erc20.wasm --from meme --chain-id=meme-local-1 --gas auto --gas-adjustment 1.3 -b block --keyring-backend test --output json -y | jq -r '.txhash')
#C5D5AC1326D6227D7F051774AC6321B9B9CCA3F71656EF1C1A76F8948E87BFF1

CODE_ID=$(memed query tx $TX --output json | jq -r '.logs[0].events[-1].attributes[0].value')
#1

```
