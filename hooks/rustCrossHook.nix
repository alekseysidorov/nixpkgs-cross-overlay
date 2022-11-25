{ makeSetupHook, stdenv, lib }:

let
  cargoBuildTarget = lib.strings.removeSuffix "-" stdenv.cc.targetPrefix;
  cargoLinkerInfix = builtins.replaceStrings [ "-" "." ] [ "_" "_" ] (lib.toUpper cargoBuildTarget);
  # Override cargo target dir in order to make it easier to write 
  # complex build scripts
  cargoBuildDir = builtins.toString cargoBuildTarget;
in
makeSetupHook
{
  name = "rust-cross-hook";

  substitutions = {
    inherit cargoBuildTarget cargoLinkerInfix cargoBuildDir;

    nativePrefix = stdenv.cc.nativePrefix;
    targetPrefix = stdenv.cc.targetPrefix;
    # Fix segfaults in the Rust code, see this issue:
    # https://github.com/rust-lang/rust/issues/93084
    targetRustcFlags = "-Ctarget-feature=-crt-static";
  };
} ./rust-cross-hook.sh
