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
    cmake
    pkg-config
    protobuf
    rustup
    git
    dprint
    pkgs.rustCrossHook
  ];

  buildInputs = with pkgs; [
    cargoDeps.rocksdb-sys
    cargoDeps.rdkafka-sys
    libopus
    openssl.dev
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
  ];
})
