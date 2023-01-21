#!/bin/bash

set -eo pipefail

script_dir="$( dirname -- "$BASH_SOURCE"; )";

cargo clean --manifest-path ${script_dir}/Cargo.toml
cargo build --manifest-path ${script_dir}/Cargo.toml -vv
