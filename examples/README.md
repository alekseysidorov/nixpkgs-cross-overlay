## Standalone Rust Shell

 A standalone nix shell file to setup Rust cross-compilation toolchain.

 This file does not have any additional dependencies and is completely self-sufficient.
 You can use the `nix-shell` command and get the working cross-compilation toolchain.
 By default, it produces completely static binaries, which can be placed into the 
 Alpine Linux container as is.
 
 ### Usage:

 ```shell
 nix-shell ./shell-rust-cross.nix
 ```

 ### Tips:

 - You can attach a binary cache by running the command:
   `nix-shell -p cachix --run "cachix use nixpkgs-cross-overlay"`
 - If you have compilation issues, try to add `--pure` argument to the `nix-shell`.
