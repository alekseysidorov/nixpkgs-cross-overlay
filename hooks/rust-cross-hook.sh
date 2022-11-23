
populateRustCrossEnv () {
    # Setup cargo
    export CARGO_BUILD_TARGET=@cargoBuildTarget@
    export @linkerPrefix@=@targetPrefix@cc
    export RUSTFLAGS=@rustcFlags@;
    # Setup compilers
    export HOST_CC=@nativePrefix@cc;
    export HOST_CXX=@nativePrefix@cpp;
    export TARGET_CC=@targetPrefix@cc;
    export TARGET_CXX=@targetPrefix@cpp;
}

postHook="${postHook:-}"$'\n'"populateRustCrossEnv"$'\n'
