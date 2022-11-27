# Example Linux musl64 shell
{ pkgs, lib, stdenv, darwin, libiconv, }:

pkgs.mkShell ({
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    protobuf
    rustup
    git
    pkgs.pkgsHostHost.rustCrossHook
  ];

  buildInputs = with pkgs; [
    cargoDeps.rust-rocksdb-sys
    rdkafka
    libopus
    openssl.dev
  ]
  # Some additional libraries for the Darwin platform
  ++ lib.optionals stdenv.isDarwin [
    libiconv
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.Security
  ];
})
