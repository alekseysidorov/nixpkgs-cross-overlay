{ mkEnvHook
, stdenv
, rdkafka
, cmake
, openssl
, zlib
, lz4
, zstd
, pkgs
}:

mkEnvHook {
  name = "cargo-rdkafka-sys";

  deps = [
    lz4
    openssl.dev
    openssl.dev
    rdkafka
    zlib.dev
    zstd
  ];

  envVariables = {
    CARGO_FEATURE_DYNAMIC_LINKING = true;
    CARGO_FEATURE_EXTERNAL_LZ4 = true;
    CARGO_FEATURE_ZSTD_PKG_CONFIG = true;
    CARGO_FEATURE_SSL = true;
  };
}
