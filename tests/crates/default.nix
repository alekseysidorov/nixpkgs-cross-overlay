{ pkgs
, cargoDeps
, rustBuildHostDependencies
}:
let
  # # Setup rust toolchain
  rustToolchain = pkgs.pkgsBuildHost.rust-bin.stable.latest.default;
  rustPlatform = pkgs.makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };
in
rustPlatform.buildRustPackage {
  pname = "crates-test";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
  ]
  # Build also all cargo deps
  ++ cargoDeps.all;

  # Fix Rust cross-compilation issues.
  buildInputs = with pkgs; [
    rustCrossHook
  ];
}
