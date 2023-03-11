{ mkEnvHook
, stdenv
, rdkafka
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
      propagatedBuildInputs = [
        pkgs.pkgsBuildHost.cmake
      ];
      depsTargetTargetPropagated = [
        openssl.dev
      ];
      envVariables = { };
    } else {
      # We can just rdkafka nix package.
      propagatedBuildInputs = [
        pkgs.pkgsBuildHost.pkg-config
      ];
      depsTargetTargetPropagated = [
        lz4.dev
        openssl.dev
        rdkafka
        zlib.dev
        zstd.dev
      ];
      # We have to force a several cargo features in the rdkafka
      envVariables = {
        CARGO_FEATURE_DYNAMIC_LINKING = true;
        CARGO_FEATURE_EXTERNAL_LZ4 = true;
        CARGO_FEATURE_ZSTD_PKG_CONFIG = true;
      };
    };
in
mkEnvHook ({
  name = "cargo-rdkafka-sys";
} // out)
