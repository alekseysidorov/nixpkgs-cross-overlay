# An example of a local cross-compilation without `flakes`.
let 
  target = "x86_64-unknown-linux-musl";

  lock = import ./../../utils/flake-lock.nix { src = ./.; };
in {
  inherit lock;
}
