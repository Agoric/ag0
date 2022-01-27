#! /bin/bash
cp -a build.linux/node[1-9]/gaiad/keyring-test/* build.linux/node0/gaiad/keyring-test/
jq '. * { app_state: { gov: { voting_params: { voting_period: "240s" } } } }' \
  build.linux/node0/gaiad/config/genesis.json > build.linux/node0/gaiad/config/genesis.json.new
for node in build.linux/node*; do
  cp build.linux/node0/gaiad/config/genesis.json.new "$node"/gaiad/config/genesis.json || exit $?
done
