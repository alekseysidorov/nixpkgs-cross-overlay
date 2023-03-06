{ makeSetupHook
, stdenv
, lib
, runCommand
, llvm-gcc_s-compat
, rust
}:

let
  # FIXME: This workaround was taken from the
  # https://github.com/oxalica/rust-overlay/blob/be3a8a8b59aaec5cd96d3ea6e4470bd14bdd8b37/rust-overlay.nix#L18
  toRustTarget = platform:
    if platform.isWasi then
      "${platform.parsed.cpu.name}-wasi"
    else
      rust.toRustTarget platform;

  cargoBuildTarget = toRustTarget stdenv.targetPlatform;
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
  propagatedBuildInputs = lib.optionals (stdenv.cc.isClang && !stdenv.targetPlatform.isStatic) [ llvm-gcc_s-compat ];
} ./rust-cross-hook.sh
