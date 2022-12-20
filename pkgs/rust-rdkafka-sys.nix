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
  pkg-config = pkgs.pkgsBuildHost.pkg-config;

  out =
    if isStatic then {
      # Since there is lack of static linking via pkg-config in rdkafka-sys we
      # cannot use the rdkafka nix package.
      deps = [
        cmake
        openssl.dev
        zlib.dev
        lz4
        zstd
      ];
      # We can force a several cargo features in the rdkafka
      envVariables = {
        CARGO_FEATURE_CMAKE_BUILD = true;
        CARGO_FEATURE_EXTERNAL_LZ4 = true;
        CARGO_FEATURE_ZSTD = true;
        CARGO_FEATURE_SSL = true;
      };
    } else {
      # We can just rdkafka nix package.
      deps = [
        pkg-config
        rdkafka
        openssl.dev
      ];

      envVariables = {
        CARGO_FEATURE_DYNAMIC_LINKING = true;
        CARGO_FEATURE_EXTERNAL_LZ4 = true;
        CARGO_FEATURE_ZSTD = true;
        CARGO_FEATURE_SSL = true;
      };
    };
in
mkEnvHook {
  name = "rust-rdkafka-sys";

  deps = out.deps;
  envVariables = out.envVariables;
}
