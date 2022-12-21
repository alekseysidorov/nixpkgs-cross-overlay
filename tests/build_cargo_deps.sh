#!/bin/bash

set -euo

script_dir="$( dirname -- "$BASH_SOURCE"; )";

cargo clean --manifest-path ${script_dir}/Cargo.toml
cargo build -vv --manifest-path ${script_dir}/Cargo.toml
