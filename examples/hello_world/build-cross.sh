#!/bin/sh

echo "-> compiling for musl64 target"
nix develop -c cargo build

echo "-> compiling for gnu64 target"
nix develop ".#gnu64" -c cargo build
