final: prev:
let
  lib = prev.lib;
  stdenv = prev.stdenv;
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

  defaultTargetPlatform = if isCross then stdenv.targetPlatform.config else "";
in
rec {
  rustCrossHook = final.callPackage ./hooks/rustCrossHook.nix { };
  mkEnvHook = final.callPackage ./hooks/mkEnvHook.nix { };

  # Rust host dependencies
  rustBuildHostDependencies = prev.callPackage
    ({ pkgs
     , darwin
     , libiconv
     , lib
     }:
      [
        prev.pkgsBuildHost.git
        prev.pkgsBuildHost.zlib.dev
      ]
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

  # Nice shell prompt maker
  mkBashPrompt = envName: ''
    PS1="\[\033[38;5;39m\]\w \[\033[38;5;35m\](${envName}) \[\033[0m\]\$ "
  '';
  crossBashPrompt = mkBashPrompt final.stdenv.targetPlatform.config;

  # Utility to copy built by cargo binary into the `bin` directory.
  # Can be used to copy binaries built by the `nix-shell` with the corresponding Rust 
  # toolchain to the docker images.
  copyBinaryFromCargoBuild =
    { name
    , targetDir
    , profile ? "release"
    , targetPlatform ? defaultTargetPlatform
    , buildInputs ? [ ]
    , derivationArgs ? { inherit buildInputs; }
    }:
    let
      cargo-binary-path = targetDir + "/${targetPlatform}/${profile}/${name}";
      # Add an extra build inputs to the derivation args
      commandEnv = derivationArgs // {
        buildInputs =
          [
            stdenv.cc.libc_lib
          ]
          # Non-gnu platforms use llvm libunwind replacement for libgcc_s.
          ++ lib.optionals (!stdenv.targetPlatform.isGnu) [
            final.llvm-gcc_s-compat
          ]
          ++ lib.optionals (builtins.hasAttr "buildInputs" derivationArgs) derivationArgs.buildInputs
        ;
      };
    in
    prev.runCommand
      "copy-cargo-${name}-bin"
      commandEnv
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
} // (import ./pkgs final prev)
