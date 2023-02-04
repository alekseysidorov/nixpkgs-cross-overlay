{ mkEnvHook
, rocksdb
, snappy
, pkgs
, lib
, stdenv
, llvmPackages
, libcxx-gcc-compat
}:

mkEnvHook {
  name = "cargo-rocksdb-sys";

  deps = [
    pkgs.pkgsBuildBuild.rustPlatform.bindgenHook
    rocksdb
  ]
  # The rocksdb build script thinks that Linux targets can have only the `libstdc++` library.
  # We have to pretend that the `libc++` is the `libstdc++`.
  ++ lib.optionals stdenv.cc.isClang [ libcxx-gcc-compat ];

  envVariables = {
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    SNAPPY_LIB_DIR = "${snappy}/lib";
  };
}
