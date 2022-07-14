#! /bin/sh
case "$1" in
tx | keys)
  set dummy --keyring-backend=test ${1+"$@"}
  shift
  ;;
esac
exec ./build/ag0 --home=build.linux/node0/gaiad ${1+"$@"}
