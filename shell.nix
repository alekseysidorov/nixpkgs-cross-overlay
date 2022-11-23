# Example Linux musl64 shell
{ pkgs, rustCrossHook }:

pkgs.mkShell ({
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
    rustup
    git
    pkgs.rustCrossHook
  ];

  buildInputs = with pkgs; [
    rdkafka
    rocksdb
    libopus
    openssl.dev
  ];

  # Env variables for the rocksdb crate
  ROCKSDB_LIB_DIR = "${pkgs.rocksdb}/lib";
  SNAPPY_LIB_DIR = "${pkgs.snappy}/lib";
})
