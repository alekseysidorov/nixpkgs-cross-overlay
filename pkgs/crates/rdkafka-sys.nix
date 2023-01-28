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

let
  isStatic = stdenv.targetPlatform.isStatic;

  out =
    if isStatic then {
      # Since there is lack of static linking via pkg-config in rdkafka-sys we
      # cannot use the rdkafka nix package.
      deps = [
        lz4.dev
        openssl.dev
        zlib.dev
        zstd.dev
      ];
      # We can force a several cargo features in the rdkafka
      envVariables = {
        CARGO_FEATURE_EXTERNAL_LZ4 = true;
        CARGO_FEATURE_ZSTD_PKG_CONFIG = true;
        CARGO_FEATURE_SSL = true;
      };
    } else {
      # We can just rdkafka nix package.
      deps = [
        lz4.dev
        openssl.dev
        rdkafka
        zlib.dev
        zstd.dev
      ];

      envVariables = {
        CARGO_FEATURE_DYNAMIC_LINKING = true;
        CARGO_FEATURE_EXTERNAL_LZ4 = true;
        CARGO_FEATURE_ZSTD_PKG_CONFIG = true;
        CARGO_FEATURE_SSL = true;
      };
    };
in
mkEnvHook {
  name = "cargo-rdkafka-sys";

  deps = out.deps;
  envVariables = out.envVariables;
}
