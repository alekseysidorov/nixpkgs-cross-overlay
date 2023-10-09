#!/usr/bin/env bash

populateRustCrossEnv () {
  # Setup cargo
  export CARGO_BUILD_TARGET=@cargoBuildTarget@
  export CARGO_TARGET_@cargoLinkerInfix@_LINKER=@targetPrefix@cc
  export RUSTFLAGS=@targetRustcFlags@"${RUSTFLAGS-}"
  # Setup compilers
  export HOST_CC=@nativePrefix@cc
  export HOST_CXX=@nativePrefix@c++
  export TARGET_CC=@targetPrefix@cc
  export TARGET_CXX=@targetPrefix@c++
}

postHook="${postHook:-}"$'\n'"populateRustCrossEnv"$'\n'
