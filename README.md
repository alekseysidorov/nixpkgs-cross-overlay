# nixpkgs-cross-overlay

Nix Package Manager has incredible cross-compilation support, but vanilla packages
sometimes have some cross-compilation issues. This overlay contains some extensions
and bugfixes to provide a better experience.

nixpkgs-cross-overlay targets `nixpkgs-unstable` channel, they are tested on CI.
It may also work on other channels but it is not guaranteed.

## Usage examples

- [Standalone cross compilation Rust Shell](./examples/README.md)
- [Rust service packaged to a docker image](https://github.com/alekseysidorov/nixpkgs-rust-service-example)

## Features

This overlay is in an early development stage, so there is a lack of documentation,
especially about useful extensions like `rustCrossHook`. Anyway, a contribution is very welcome.

- Works fine on the Intel and Silicon macOS machines.
- Compilation fixes and workarounds for the some libraries and binaries.
- Static Musl targets, that can produce distro-independent binaries.
- Almost zero cross-compilation shell setup for Rust by the `rustCrossHook`
  and `rustBuildHostDependencies` hooks.
- Binary cache with the precompilled [packages](https://app.cachix.org/cache/nixpkgs-cross-overlay#pull).

## License

MIT licensed.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion
by you, shall be licensed as MIT, without any additional terms or conditions.
