final: prev:
let
  lib = prev.lib;
  stdenv = prev.stdenv;
  isCross = stdenv.hostPlatform != stdenv.buildPlatform;
  isStatic = stdenv.targetPlatform.isStatic;
  isClang = stdenv.cc.isClang;

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
  # Metapackage with all crates dependencies.
  cargoDeps = (import ./crates prev);
  # Link libc++ libraries together just like it's done in the Android NDK.
  libcxx-full-static = prev.callPackage ./libcxx_static { };
  # Use llvm_unwind as libgcc_s replacement on the LLVM targets.
  llvm-gcc_s-compat = prev.runCommand
    "llvm-gcc_s-compat"
    {
      propagatedBuildInputs = [
        final.llvmPackages.libunwind
      ];
    }
    ''
      mkdir -p $out/lib
      libdir=${final.llvmPackages.libunwind}/lib
      for dylibtype in so dylib a dll; do
        if [ -e "$libdir/libunwind.$dylibtype" ]; then
          ln -svf $libdir/libunwind.$dylibtype $out/lib/libgcc_s.$dylibtype
        fi
      done
    '';
  # Use libcxx as libstdc++ replacement on the LLVM targets.
  # It can fix some crates like Rocksdb that relies that there is only `libstdc++` 
  # on Linux systems.
  libcxx-gcc-compat =
    let
      compat-dynamic = final.runCommand
        "libcxx-gcc-compat-dynamic"
        {
          propagatedBuildInputs = [
            final.llvmPackages.libcxx
          ];
        }
        ''
          mkdir -p $out/lib
          libdir=${final.llvmPackages.libcxx}/lib
          for dylibtype in so dylib a dll; do
            if [ -e "$libdir/libc++.$dylibtype" ]; then
              ln -svf $libdir/libc++.$dylibtype $out/lib/libstdc++.$dylibtype
            fi
          done
        '';

      compat-static = final.runCommand
        "libcxx-gcc-compat-static"
        {
          propagatedBuildInputs = [
            final.libcxx-full-static
          ];
        }
        ''
          mkdir -p $out/lib
          libdir=${final.libcxx-full-static}/lib
          ln -svf $libdir/libc++_static.a $out/lib/libstdc++.a
        '';

    in
    if isStatic then compat-static else compat-dynamic;

  # Cmake-built Kafka works better than the origin one.
  rdkafka = prev.rdkafka.overrideAttrs (now: old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.pkgsBuildHost.cmake ];
    buildInputs = old.buildInputs ++ [ final.lz4 final.openssl.dev ];
    cmakeFlags = [
      "-DRDKAFKA_BUILD_TESTS=0"
      "-DRDKAFKA_BUILD_EXAMPLES=0"
    ] ++ lib.optional isStatic "-DRDKAFKA_BUILD_STATIC=1";
  });
  # Fix rocksdb on some environments.
  rocksdb = prev.rocksdb.overrideAttrs (now: old: {
    # Fix "relocation R_X86_64_32 against `.bss._ZGVZN12_GLOBAL__N_18key_initEvE2ks'"
    cmakeFlags = old.cmakeFlags
    ++ lib.optional isStatic "-DCMAKE_POSITION_INDEPENDENT_CODE=ON";
  });
  # Fix snappy cross-compilation.
  snappy = prev.snappy.overrideAttrs (now: old: {
    # Fix "error: comparison of integers of different signs: 'unsigned long' and 'ptrdiff_t"
    env.NIX_CFLAGS_COMPILE = lib.optionalString isClang "-Wno-sign-compare";
  });
} # Special case for the cross-compilation.
  // lib.optionalAttrs isCross {
  # Fix compilation by overriding the packages attributes.
  lz4 = prev.lz4.overrideAttrs gccCrossCompileWorkaround;
  libuv = prev.libuv.overrideAttrs disableChecks;
  libopus = prev.libopus.overrideAttrs disableChecks;
  gmp = prev.gmp.overrideAttrs disableChecks;
  zlib = prev.zlib.overrideAttrs disableChecks;
}
