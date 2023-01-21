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
  # Disable checks
  disableChecks = (old: {
    doCheck = false;
  });
in
{
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

  # Nice shell prompt
  crossBashPrompt = ''
    PS1="\[\033[38;5;39m\]\w \[\033[38;5;35m\](${final.stdenv.targetPlatform.config}) \[\033[0m\]\$ "
  '';

  # Extra utils and tools
  copyBinaryFromCargoBuild =
    { name
    , targetDir
    , profile ? "release"
    , targetPlatform ? stdenv.targetPlatform.config
    , buildInputs ? [ ]
    }:
    let
      cargo-binary-path = targetDir + "/${targetPlatform}/${profile}/${name}";
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

  # Remap sources to better compatiblity with perf utils.
  cargoRemapShellHook = project:
    let
      extraRustcFlags = lib.optionalString isCross
        (
          "--remap-path-prefix=$HOME=/home/cprc"
          + " --remap-path-prefix=$PWD=/home/cprc"
        );
    in
    ''
      # Remap sources
      export RUSTFLAGS="$RUSTFLAGS ${extraRustcFlags}"
    '';
}
  # Cross-compilation specific patches
  // lib.optionalAttrs isCross {

  rustCrossHook = prev.callPackage ./hooks/rustCrossHook.nix { };
  # Patched packages
  lz4 = prev.lz4.overrideAttrs gccCrossCompileWorkaround;
  rdkafka = prev.callPackage ./libraries/rdkafka.nix { };
  # GCC 12 more strict than the old one
  rocksdb = prev.rocksdb.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
    + prev.lib.optionalString prev.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });
  # Some checks failed on the x86_64-unknown-linux-musl static target.
  libuv = prev.libuv.overrideAttrs disableChecks;
  libopus = prev.libopus.overrideAttrs disableChecks;
  gmp = prev.gmp.overrideAttrs disableChecks;
}
