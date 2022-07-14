# Agoric Upgrade 6 Testing Instructions

- Reason for upgrade:

Due to an issue fixed in v6.0.0 final, an ante-handler decorator `ante.NewSetUpContextDecorator()` was not included, resulting in cumulative gas caluculation.

# Testing instructions

Prerequisites:
- Be on linux
- have docker installed and running
- have docker-compose installed

### Run:

```sh
basebranch=agoric-upgrade-5
baseupgradename=agoric-upgrade-5
toupgradename=agoric-upgrade-6
git checkout $basebranch
rm build.linux/ag0
make build build-linux
make localnet-start
```

### Ensure nodes are alive
```sh
./ag0.sh status | jq .SyncInfo
chainid=$( ./ag0.sh status | jq -r .NodeInfo.network )
```

### Generate load
```sh
while true; do
  for f in `seq 0 3`; do
    block=""
    if (( f == 3 )); then
      block="-bblock"
    fi
    ./ag0.sh tx distribution withdraw-all-rewards --from=node$f --chain-id="$chainid" --yes $block
  done
  ./ag0.sh status | jq .SyncInfo
done
```

### Query transactions at a specific height:
```sh
./ag0.sh query txs --events=tx.height=30
```

Note: In the bugged version, in a block with multiple tx, the gas_used is cumulative. For example:
```
./ag0.sh query txs --events=tx.height=32 | grep gas_used
  gas_used: "325991"
  gas_used: "410011"
  gas_used: "494031"
  gas_used: "578051"
```
After this update, the gas for the load transactions above should all be the same for each transaction


### Propose software upgrade governance:

```sh
latest_height=$(./ag0.sh status | jq -r .SyncInfo.latest_block_height)
height=$(( $latest_height + $voting_period_s / 3 ))
voting_period_s=240
./ag0.sh tx gov submit-proposal software-upgrade $toupgradename --upgrade-height="$height" \
  --title="Upgrade to ${toupgradename}" --description="Fixes gas calculation" \
  --from=node0 --chain-id="$chainid" -bblock --yes
```

### Add deposit and votes.

```sh
proposal=1
./ag0.sh tx gov deposit $proposal 10000000stake --from=node0 --chain-id="$chainid" -bblock --yes
for f in `seq 0 3`; do
  ./ag0.sh tx gov vote $proposal yes --from=node$f --chain-id="$chainid" --yes
done
```
### Wait until the nodes stop due to upgrade.

```sh
watch ./check-prop-status.sh $proposal ./ag0.sh
```


### build and apply new version

```sh
git checkout $newupgrade
make localnet-stop

#juggle out the build_dir due to go trying to read files owned by root
mv build.linux _build.linux
make build-linux
mv build.linux/ag0 _build.linux/ag0
rm -rf build.linux
mv _build.linux build.linux

docker-compose up -d
docker-compose logs -f gaiadnode0
```

### Validate

Run the load transactions from above, and validate that gas is lower and similar for the multiple transactions, and not cumulative.

```
 ./ag0.sh query txs --events=tx.height=157 | grep gas_used
  gas_used: "77552"
  gas_used: "77642"
  gas_used: "77642"
  gas_used: "77642"
```
