#!/bin/sh

set -euo pipefail

target=$1
extra_args=""
build_type=${2:-dynamic}
if [ $build_type == "static" ]
then
    extra_args="--arg isStatic true"
fi

echo "-> compiling for '${target}:${build_type}' target"; set -x;
nix-shell --argstr config $target $extra_args --run "cargo build --release"
docker load < $(nix-build dockerImage.nix --argstr config $target $extra_args)
