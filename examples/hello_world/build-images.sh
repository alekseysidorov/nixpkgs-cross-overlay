#!/bin/sh

echo "-> compiling for musl64 target"
nix-shell -A shell --argstr config "x86_64-unknown-linux-musl"  --run "cargo build --release"
docker load < $(nix-build -A dockerImage --argstr config "x86_64-unknown-linux-musl")

echo "-> compiling for gnu64 target"
nix-shell -A shell --argstr config "x86_64-unknown-linux-gnu"  --run "cargo build --release"
docker load < $(nix-build -A dockerImage --argstr config "x86_64-unknown-linux-gnu")

echo "-> compiling for gnu-static target"
nix-shell -A shell --argstr config "x86_64-unknown-linux-gnu" --arg isStatic true  --run "cargo build --release"
docker load < $(nix-build -A dockerImage --argstr config "x86_64-unknown-linux-gnu" --arg isStatic true)

echo "-> compiling for musl64-static target"
nix-shell -A shell --argstr config "x86_64-unknown-linux-musl" --arg isStatic true  --run "cargo build --release"
docker load < $(nix-build -A dockerImage --argstr config "x86_64-unknown-linux-musl" --arg isStatic true)
