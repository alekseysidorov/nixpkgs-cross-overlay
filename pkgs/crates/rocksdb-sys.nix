{ mkEnvHook
, rocksdb
, snappy
, pkgs
, lib
, stdenv
, llvmPackages
, llvmLibcxxCompat
}:

mkEnvHook {
  name = "cargo-rocksdb-sys";

  deps = [
    pkgs.pkgsBuildBuild.rustPlatform.bindgenHook
    rocksdb
  ]
  # The rocksdb build script thinks that Linux targets can have only the `libstdc++` library.
  # We have to pretend that the `libc++` is the `libstdc++`.
  ++ lib.optionals stdenv.cc.isClang [ llvmLibcxxCompat ];

  envVariables = {
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    SNAPPY_LIB_DIR = "${snappy}/lib";
  }
  // lib.optionalAttrs (stdenv.cc.isClang && stdenv.targetPlatform.isStatic) {
    # In static linking, in addition to the `libc++` as is, it must additionally 
    #link with the `libc++abi`, which the build script can't do.
    RUSTFLAGS = "\" -L${llvmPackages.libcxxabi}/lib -lc++abi\"" + "\${RUSTFLAGS-}";
  }
  ;
}
