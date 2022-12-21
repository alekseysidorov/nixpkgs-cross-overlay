final: prev:
let
  lib = prev.lib;
  stdenv = prev.stdenv;

  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

  # Fix 'x86_64-unknown-linux-musl-gcc: error: unrecognized command-line option' error
  gccCrossCompileWorkaround = (final: prev: {
    #ToDo more precise
    UNAME = ''echo "Linux"'';
    TARGET_OS = "Linux";
  });
in
rec {
  rustCrossHook = null;

  mkEnvHook = prev.callPackage ./hooks/mkEnvHook.nix { };

  # Rust host dependencies
  rustBuildHostDependencies = prev.callPackage
    ({ pkgs
     , darwin
     , libiconv
     , lib
     }: [ ]
    # Some additional libraries for the Darwin platform
    ++ lib.optionals stdenv.isDarwin [
      libiconv
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
      darwin.apple_sdk.frameworks.IOKit
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ])
    { };

  cargoDeps = (import ./crates prev);

  copyBinaryFromCargoBuild =
    { name
    , targetDir
    , profile ? "release"
    , targetPlatform ? stdenv.targetPlatform.config
    , buildInputs ? [ ]
    }:
    let
      cargo-binary-path = "${targetDir}/${targetPlatform}/${profile}/${name}";
    in
    prev.runCommand
      "copy-cargo-${name}-bin"
      {
        buildInputs = buildInputs ++ [
          stdenv.cc.cc.lib
          stdenv.cc.libc
        ];
      }
      ''
        mkdir -p $out/bin
        cp ${cargo-binary-path} $out/bin/${name}
        chmod +x $out/bin/${name}
      '';
}
  # Cross-compilation specific patches
  // lib.optionalAttrs isCross {

  rustCrossHook = prev.callPackage ./hooks/rustCrossHook.nix { };
  # Patched packages
  lz4 = prev.lz4.overrideAttrs gccCrossCompileWorkaround;
  rdkafka = prev.callPackage ./libraries/rdkafka.nix { };
  # GCC 12 more strict than the old one
  rocksdb = prev.rocksdb.overrideAttrs (old: rec {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
    + prev.lib.optionalString prev.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });
  # libuv checks failed on the x86_64-unknown-linux-musl static target.
  libuv = prev.libuv.overrideAttrs (old: rec {
    doCheck = false;
  });
}
