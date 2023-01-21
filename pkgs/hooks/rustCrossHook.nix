{ makeSetupHook, stdenv, lib, runCommand, llvmPackages }:

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
  # Use llvm_unwind as libgcc_s replacement on the LLVM targets.
  llvmGccCompat = runCommand
    "llvm-gcc_s-compat"
    {
      buildInputs = [
        llvmPackages.libunwind
      ];
    }
    ''
      mkdir -p $out/lib
      libdir=${llvmPackages.libunwind}/lib    
      for dylibtype in so dylib a dll; do
        if [ -e "$libdir/libunwind.$dylibtype" ]; then
          ln -svf $libdir/libunwind.$dylibtype $out/lib/libgcc_s.$dylibtype
        fi
      done
    '';
in
makeSetupHook
{
  name = "rust-cross-hook";

  substitutions = {
    inherit cargoBuildTarget cargoLinkerInfix cargoBuildDir targetRustcFlags;

    nativePrefix = stdenv.cc.nativePrefix;
    targetPrefix = stdenv.cc.targetPrefix;
  };
  deps = lib.optionals stdenv.cc.isClang [ llvmGccCompat ];
} ./rust-cross-hook.sh
