# Agoric Upgrade 7 Testing Instructions

- Reason for upgrade:

To align with Gaia v7.0.2, this release upgrades ag0 from agoric-upgrade-6 (v6.0.0-rc1) to v7.0.2

# Testing instructions

Prerequisites:
- Be on linux
- have docker installed and running
- have docker-compose installed

### Run:

```sh
baseupgradename=agoric-upgrade-6
toupgradename=agoric-upgrade-7
git checkout tags/$baseupgradename
rm -rf build.linux
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

### Propose software upgrade governance:

```sh
latest_height=$(./ag0.sh status | jq -r .SyncInfo.latest_block_height)
voting_period_s=240
height=$(( $latest_height + $voting_period_s / 4 ))
./ag0.sh tx gov submit-proposal software-upgrade $toupgradename --upgrade-height="$height" \
  --title="Upgrade to ${toupgradename}" --description="upgrades ag0 to v7.0.2 ${toupgradename}" \
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
make localnet-stop
git checkout tags/$toupgradename

#juggle out the build_dir due to go trying to read files owned by root
mv build.linux _build.linux
make build-linux
mv build.linux/ag0 _build.linux/ag0
rm -rf build.linux
mv _build.linux build.linux
docker-compose up -d
docker-compose logs -f gaiadnode0
```
