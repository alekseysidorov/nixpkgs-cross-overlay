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
    openssl.dev
    zlib.dev
    lz4
    zstd
    rdkafka
  ];

  envVariables = {
    CARGO_FEATURE_DYNAMIC_LINKING = true;
    CARGO_FEATURE_EXTERNAL_LZ4 = true;
    CARGO_FEATURE_ZSTD_PKG_CONFIG = true;
    CARGO_FEATURE_SSL = true;

    OPENSSL_INCLUDE_DIR = "${openssl.dev}/include";
    OPENSSL_ROOT_DIR = "${openssl.out}";
  };
}
