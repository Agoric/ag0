Run:

```sh
git checkout mfig-localnet-3.1
make localnet-start
cp build.linux/ag0{,-agoric-3.1}
```

Propose software upgrade governance:

```sh
voting_period_s=240
latest_height=$(./ag0.sh status | jq -r .SyncInfo.latest_block_height)
height=$(( $latest_height + $voting_period_s / 3 ))
chainid=$( ./ag0.sh status | jq -r .NodeInfo.network )
./ag0.sh tx gov submit-proposal software-upgrade agoric-3.2 --upgrade-height="$height" \
  --title="Enable true vesting accounts" --description="allow bla bla bla" \
  --from=node0 --chain-id="$chainid" -bblock
```

Add deposit and votes.

```sh
proposal=2
./ag0.sh tx gov deposit $proposal 10000000stake --from=node0 --chain-id="$chainid" -bblock --yes
for f in `seq 0 3`; do
  ./ag0.sh tx gov vote $proposal yes --from=node$f --chain-id="$chainid" -bblock --yes
done
```

Wait until the nodes stop due to upgrade.

```sh
./check-prop-status.sh $proposal ./ag0.sh
```

```sh
git checkout mfig-localnet-3.2
make localnet-start
```
