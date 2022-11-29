# Example Linux musl64 shell
{ pkgs
, lib
, stdenv
, darwin
, libiconv
, rustBuildHostDependencies
}:

pkgs.mkShell ({
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    protobuf
    rustup
    git
    pkgs.rustCrossHook
  ];

  buildInputs = with pkgs; [
    cargoDeps.rust-rocksdb-sys
    rdkafka
    libopus
    openssl.dev
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
  ];
})
