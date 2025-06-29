{ mkEnvHook
, rocksdb
, snappy
, lib
, stdenv
, libcxx-gcc-compat
, cargoDeps
}:
mkEnvHook {
  name = "rocksdb-sys";

  propagatedBuildInputs = [ cargoDeps.bindgen ];
  depsTargetTargetPropagated = [ rocksdb ]
    # The rocksdb build script thinks that Linux targets can have only the `libstdc++` library.
    # We have to pretend that the `libc++` is the `libstdc++`.
    ++ lib.optionals stdenv.cc.isClang [ libcxx-gcc-compat ];

  env = {
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
    SNAPPY_LIB_DIR = "${snappy}/lib";
  };
}
