#!/bin/sh

echo "-> compiling for musl64 target"
nix-shell --argstr config "x86_64-unknown-linux-musl"  --run "cargo build --release"
docker load < $(nix-build dockerImage.nix --argstr config "x86_64-unknown-linux-musl")

echo "-> compiling for gnu64 target"
nix-shell --argstr config "x86_64-unknown-linux-gnu"  --run "cargo build --release"
docker load < $(nix-build dockerImage.nix --argstr config "x86_64-unknown-linux-gnu")
