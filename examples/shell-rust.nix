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
    pkgs.rustCrossHook
  ];

  buildInputs = with pkgs; [
    cargoDeps.rocksdb-sys
    cargoDeps.rdkafka-sys
    libopus
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
  ];
})
