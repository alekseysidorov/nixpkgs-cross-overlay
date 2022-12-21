{ mkEnvHook
, rocksdb
, snappy
, pkgs
}:

mkEnvHook {
  name = "cargo-rocksdb-sys";

  deps = [
    pkgs.pkgsBuildHost.rustPlatform.bindgenHook
    rocksdb
    snappy
  ];

  envVariables = {
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    SNAPPY_LIB_DIR = "${snappy}/lib";
  };
}
