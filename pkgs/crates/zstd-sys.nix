{ mkEnvHook
, pkgs
, zstd
}:

mkEnvHook {
  name = "cargo-zstd-sys";

  deps = [
    pkgs.pkgsBuildBuild.pkg-config
    zstd
  ];
}
