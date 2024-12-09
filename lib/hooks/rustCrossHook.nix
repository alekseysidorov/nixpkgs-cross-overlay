{ makeSetupHook
, stdenv
, lib
, llvm-gcc_s-compat
}:

let
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;

  cargoBuildTarget = stdenv.hostPlatform.rust.rustcTarget;
  cargoLinkerInfix = builtins.replaceStrings [ "-" "." ] [ "_" "_" ] (lib.toUpper cargoBuildTarget);
  # Override cargo target dir in order to make it easier to write
  # complex build scripts
  cargoBuildDir = builtins.toString cargoBuildTarget;
  # Fix segfaults in the Rust code, see this issue:
  # https://github.com/rust-lang/rust/issues/93084
  targetRustcFlags =
    if stdenv.targetPlatform.isStatic then "-Ctarget-feature=+crt-static"
    else "-Ctarget-feature=-crt-static";
  # Cross hook dependencies
  hookDeps =
    # Use llvm_unwind as libgcc_s replacement on the LLVM targets.
    lib.optionals (stdenv.cc.isClang && !stdenv.targetPlatform.isStatic) [ llvm-gcc_s-compat ];

  crossHook = (makeSetupHook
    {
      name = "rust-cross-hook";

      substitutions = {
        inherit cargoBuildTarget cargoLinkerInfix cargoBuildDir targetRustcFlags;

        nativePrefix = stdenv.cc.nativePrefix;
        targetPrefix = stdenv.cc.targetPrefix;
      };
      depsTargetTargetPropagated = hookDeps;
      propagatedBuildInputs = hookDeps;
    }
    ./rust-cross-hook.sh
  );
in
if isCross then crossHook else null
