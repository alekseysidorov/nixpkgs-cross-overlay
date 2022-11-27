self: super:
let
  lib = super.lib;
  stdenv = super.stdenv;

  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

  # Fix 'x86_64-unknown-linux-musl-gcc: error: unrecognized command-line option' error
  gccCrossCompileWorkaround = (self: super: {
    #ToDo more precise
    UNAME = ''echo "Linux"'';
    TARGET_OS = "Linux";
  });
in
{
  inherit gccCrossCompileWorkaround;

  mkEnvHook = super.callPackage ./hooks/mkEnvHook.nix { };

  rustCrossHook = null;

  # Rust crates system deps
  cargoDeps = {
    rust-rocksdb-sys = super.callPackage ./pkgs/rust-rocksdb-sys.nix { };
  };

  # Applies some patches on the nix packages to better cross-compilation support.
  mkCrossPkgs =
    { src
    , system
    , crossSystem
    }:
    let
      localPkgs = import src { inherit system; };

      patchedPkgs = localPkgs.applyPatches {
        name = "patched-pkgs";
        inherit src;
        # Pathces gcc to be buildable on M1 mac
        # See https://github.com/NixOS/nixpkgs/issues/137877#issuecomment-1282126233
        patches = [
          ./patches/gcc-darwin-fix.patch
        ];
      };

      crossOverlay = import ./.;
    in
    import patchedPkgs {
      inherit system crossSystem;
      overlays = [ crossOverlay ];
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
    super.runCommand
      "copy-cargo-${name}-bin"
      { inherit buildInputs; }
      ''
        mkdir -p $out/bin
        cp ${cargo-binary-path} $out/bin/${name}
        chmod +x $out/bin/${name}
      '';
}
  # Cross-compilation specific patches
  // lib.optionalAttrs isCross {

  rustCrossHook = super.callPackage ./hooks/rustCrossHook.nix { };
  # Patched packages
  lz4 = super.lz4.overrideAttrs self.gccCrossCompileWorkaround;
  rdkafka = super.callPackage ./pkgs/rdkafka.nix { };
  # GCC 12 more strict than the old one
  rocksdb = super.rocksdb.overrideAttrs (old: rec {
    NIX_CFLAGS_COMPILE = old.NIX_CFLAGS_COMPILE
    + super.lib.optionalString super.stdenv.cc.isGNU
      " -Wno-error=format-truncation= -Wno-error=maybe-uninitialized";
  });
}
