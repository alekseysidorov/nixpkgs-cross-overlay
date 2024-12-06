{ mkEnvHook
, rocksdb
, snappy
, lib
, stdenv
, libcxx-gcc-compat
, pkgs
}:
let
  bindgenHook = pkgs.pkgsBuildBuild.rustPlatform.bindgenHook;
in
mkEnvHook {
  name = "cargo-rocksdb-sys";

  propagatedBuildInputs = [
    bindgenHook
  ];
  depsTargetTargetPropagated = [
    rocksdb
  ]
  # The rocksdb build script thinks that Linux targets can have only the `libstdc++` library.
  # We have to pretend that the `libc++` is the `libstdc++`.
  ++ lib.optionals stdenv.cc.isClang [ libcxx-gcc-compat ];

  env = {
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    SNAPPY_LIB_DIR = "${snappy}/lib";
  };
}
