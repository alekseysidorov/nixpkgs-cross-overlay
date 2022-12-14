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

  # Rust crates system deps
  cargoDeps = {
    rust-rocksdb-sys = prev.callPackage ./pkgs/rust-rocksdb-sys.nix { };

    # The special hook to list all cargo packages.
    all =
      let
        filteredDeps = lib.filterAttrs
          (name: value: name != "all")
          cargoDeps;
      in
      lib.attrValues filteredDeps;
  };

  # Applies some patches on the nix packages to better cross-compilation support.
  mkCrossPkgs =
    { src
    , localSystem
    , crossSystem
    , overlays ? [ ]
    }:
    let
      localPkgs = import src { inherit localSystem; };
      stdenv = localPkgs.stdenv;

      patchedPkgs = localPkgs.applyPatches {
        name = "patched-pkgs";
        inherit src;
        # Fix musl gcc permissions on M1 Mac.
        patches = [
          ./patches/gcc-darwin-permissions-fix.patch
        ];
      };

      nixpkgs =
        if stdenv.isDarwin && stdenv.isAarch64
        then patchedPkgs
        else src;

      crossOverlay = import ./.;
    in
    import nixpkgs {
      inherit localSystem crossSystem;
      overlays = [ crossOverlay ] ++ overlays;
    };

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
  rdkafka = prev.callPackage ./pkgs/rdkafka.nix { };
  # GCC 12 more strict than the old one
  rocksdb = prev.rocksdb.overrideAttrs (old: rec {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
    + prev.lib.optionalString prev.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });
}
