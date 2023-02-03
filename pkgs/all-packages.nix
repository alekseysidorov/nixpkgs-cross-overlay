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

  mkEnvHook = final.callPackage ./hooks/mkEnvHook.nix { };

  # Use llvm_unwind as libgcc_s replacement on the LLVM targets.
  llvmGccCompat = prev.runCommand
    "llvm-gcc_s-compat"
    {
      buildInputs = [
        prev.llvmPackages.libunwind
      ];
    }
    ''
      mkdir -p $out/lib
      libdir=${prev.llvmPackages.libunwind}/lib
      for dylibtype in so dylib a dll; do
        if [ -e "$libdir/libunwind.$dylibtype" ]; then
          ln -svf $libdir/libunwind.$dylibtype $out/lib/libgcc_s.$dylibtype
        fi
      done
    '';

  # Use libcxx as libstdc++ replacement on the LLVM targets.
  # It can fix some crates like Rocksdb that relies that there is only `libstdc++` 
  # on Linux systems.
  llvmLibcxxCompat = prev.runCommand
    "llvm-libstdc++-compat"
    {
      buildInputs = [
        prev.llvmPackages.libcxx
      ];
    }
    ''
      mkdir -p $out/lib
      libdir=${prev.llvmPackages.libcxx}/lib
      ls $libdir
      for dylibtype in so dylib a dll; do
        if [ -e "$libdir/libc++.$dylibtype" ]; then
          ln -svf $libdir/libc++.$dylibtype $out/lib/libstdc++.$dylibtype
        fi
      done
    '';

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
    , targetPlatform ? if isCross then stdenv.targetPlatform.config else ""
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
  // lib.optionalAttrs isCross {
  # Setup Rust for cross-compiling.
  rustCrossHook = final.callPackage ./hooks/rustCrossHook.nix { };
  # Patched packages
  rdkafka = prev.callPackage ./libraries/rdkafka.nix { };
  # Fix compilation by overriding the packages attributes.
  lz4 = prev.lz4.overrideAttrs gccCrossCompileWorkaround;
  libuv = prev.libuv.overrideAttrs disableChecks;
  libopus = prev.libopus.overrideAttrs disableChecks;
  gmp = prev.gmp.overrideAttrs disableChecks;
  zlib = prev.zlib.overrideAttrs disableChecks;
}
