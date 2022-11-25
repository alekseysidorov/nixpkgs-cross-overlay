#!/bin/sh

echo "-> compiling for musl64 target"
nix develop ".#x86_64-unknown-linux-musl" -c cargo build

echo "-> compiling for gnu64 target"
nix develop ".#x86_64-unknown-linux-gnu" -c cargo build
