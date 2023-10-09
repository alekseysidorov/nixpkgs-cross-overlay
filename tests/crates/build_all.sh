#!/usr/bin/env bash

set -eo pipefail

current_dir="$( dirname -- "${BASH_SOURCE[0]}"; )";

cargo clean --manifest-path "${current_dir}"/Cargo.toml "$@"
cargo build --manifest-path "${current_dir}"/Cargo.toml "$@"
