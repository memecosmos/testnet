# Upgrade MEME Node

This document describes the upgrade procedure of a `memed` full-node to a new version.

## Cosmovisor

The CosmosSDK provides a convenient process manager that wraps around the `memed` binary and can automatically swap in new binaries upon a successful governance upgrade proposal. Cosmovisor is entirely optional but recommended. More information can be found [here](https://docs.cosmos.network/master/run-node/cosmovisor.html).

### Setup

To get started with Cosmovisor first download it

```bash
go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@latest
```

Set up the environment variables

```bash
echo "# Setup Cosmovisor" >> ~/.profile
echo "export DAEMON_NAME=memed" >> ~/.profile
echo "export DAEMON_HOME=$HOME/.memed" >> ~/.profile
source ~/.profile
```

Create the appropriate directories

```bash
mkdir -p ~/.memed/cosmovisor/upgrades
mkdir -p ~/.memed/cosmovisor/genesis/bin/
cp $(which memed) ~/.memed/cosmovisor/genesis/bin/

# verify the setup. 
# It should return the same version as memed
cosmovisor version

#cosmovisor version:  1.2.0
#11:01AM INF running app args=["version"] module=cosmovisor path=/root/.memed/cosmovisor/upgrades/v2.0.5/bin/memed
#v2.0.5

```

Now `memed` can start by running

```bash
cosmovisor start
```

### Preparing an Upgrade

Cosmovisor will continually poll  the `$DAEMON_HOME/data/upgrade-info.json` for new upgrade instructions. When an upgrade is ready, node operators can download the new binary and place it under `$DAEMON_HOME/cosmovisor/upgrades/<name>/bin` where `<name>` is the URI-encoded name of the upgrade as specified in the upgrade module plan.

It is possible to have Cosmovisor automatically download the new binary. To do this set the following environment variable.

```bash
export DAEMON_ALLOW_DOWNLOAD_BINARIES=true
```

## Manual Software Upgrade

First, stop your instance of `memed`. Next, upgrade the software:

```bash
cd meme
git fetch --all && git checkout <new_version>
make install
```

::: tip
_NOTE_: If you have issues at this step, please check that you have the latest stable version of GO installed.
:::

See the [testnet repo](https://github.com/memecosmos/testnet) for details on which version is needed for which public testnet, and the [meme release page](https://github.com/memecosmos/meme/releases) for details on each release.

Your full node has been cleanly upgraded! If there are no breaking changes then you can simply restart the node by running:

```bash
memed start
```

## Reset Data

:::warning
If the version <new_version> you are upgrading to is not breaking from the previous one, you should not reset the data. If it is not breaking, you can skip to [Restart](#restart)
:::

::: warning
If you are running a **validator node** on the mainnet, always be careful when doing `memed unsafe-reset-all`. You should never use this command if you are not switching `chain-id`.
:::

::: danger IMPORTANT
Make sure that every node has a unique `priv_validator.json`. Do not copy the `priv_validator.json` from an old node to multiple new nodes. Running two nodes with the same `priv_validator.json` will cause you to get slashed due to double sign !
:::

First, remove the outdated files and reset the data. **If you are running a validator node, make sure you understand what you are doing before resetting**.

```bash
memed tendermint unsafe-reset-all  --home /root/.memed
```

Your node is now in a pristine state while keeping the original `priv_validator.json` and `config.toml`. If you had any sentry nodes or full nodes setup before, your node will still try to connect to them, but may fail if they haven't also been upgraded.