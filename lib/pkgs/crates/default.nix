# System dependencies of rust crates.
prev:
let
  lib = prev.lib;

  filteredDeps = lib.filterAttrs
    (name: value: name != "all")
    cargoDeps;

  protobuf = prev.callPackage ./protobuf.nix { };

  cargoDeps = {
    audiopus_sys = prev.callPackage ./audiopus_sys.nix { };
    rdkafka-sys = prev.callPackage ./rdkafka-sys.nix { };
    rocksdb-sys = prev.callPackage ./rocksdb-sys.nix { };
    zstd-sys = prev.callPackage ./zstd-sys.nix { };
    openssl-sys = prev.callPackage ./openssl-sys.nix { };
    # Popular crates depends on the protoc compiler
    prost = protobuf;
    tonic = protobuf;
    # The special hook to list all cargo packages.
    all = lib.attrValues filteredDeps;
  };
in
cargoDeps
