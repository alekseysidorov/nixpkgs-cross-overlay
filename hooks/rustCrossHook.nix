{ makeSetupHook, stdenv, lib }:

let
  cargoBuildTarget = lib.strings.removeSuffix "-" stdenv.cc.targetPrefix;
  cargoLinkerInfix = builtins.replaceStrings [ "-" "." ] [ "_" "_" ] (lib.toUpper cargoBuildTarget);
in
makeSetupHook
{
  name = "rust-cross-hook";

  substitutions = {
    inherit cargoBuildTarget cargoLinkerInfix;
    
    nativePrefix = stdenv.cc.nativePrefix;
    targetPrefix = stdenv.cc.targetPrefix;
    linkerPrefix = "CARGO_TARGET_${cargoLinkerInfix}_LINKER";
    # Fix segfaults in the Rust code, see this issue:
    # https://github.com/rust-lang/rust/issues/93084
    rustcFlags = "-Ctarget-feature=-crt-static";
  };
} ./rust-cross-hook.sh
