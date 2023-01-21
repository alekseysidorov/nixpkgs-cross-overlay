{ makeSetupHook, stdenv, lib, runCommand, llvmGccCompat, }:

let
  cargoBuildTarget = stdenv.targetPlatform.config;
  cargoLinkerInfix = builtins.replaceStrings [ "-" "." ] [ "_" "_" ] (lib.toUpper cargoBuildTarget);
  # Override cargo target dir in order to make it easier to write 
  # complex build scripts
  cargoBuildDir = builtins.toString cargoBuildTarget;
  # Fix segfaults in the Rust code, see this issue:
  # https://github.com/rust-lang/rust/issues/93084
  targetRustcFlags =
    if stdenv.targetPlatform.isStatic then "-Ctarget-feature=+crt-static"
    else "-Ctarget-feature=-crt-static";
in
makeSetupHook
{
  name = "rust-cross-hook";

  substitutions = {
    inherit cargoBuildTarget cargoLinkerInfix cargoBuildDir targetRustcFlags;

    nativePrefix = stdenv.cc.nativePrefix;
    targetPrefix = stdenv.cc.targetPrefix;
  };
  # Use llvm_unwind as libgcc_s replacement on the LLVM targets.
  deps = lib.optionals (stdenv.cc.isClang && !stdenv.targetPlatform.isStatic) [ llvmGccCompat ];
} ./rust-cross-hook.sh
