{ mkEnvHook
, rocksdb
, snappy
, pkgs
}:

mkEnvHook {
  name = "cargo-rocksdb-sys";

  deps = [
    pkgs.pkgsBuildBuild.rustPlatform.bindgenHook
    rocksdb
    snappy
  ];

  envVariables = {
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    SNAPPY_LIB_DIR = "${snappy}/lib";
  };
}
