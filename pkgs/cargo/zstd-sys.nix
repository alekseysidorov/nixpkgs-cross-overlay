{ mkEnvHook
, pkgs
, zstd
}:

mkEnvHook {
  name = "cargo-zstd-sys";

  deps = [
    pkgs.pkgsBuildHost.pkg-config
    zstd
  ];
}
