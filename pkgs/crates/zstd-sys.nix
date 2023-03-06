{ mkEnvHook
, pkgs
, zstd
}:

mkEnvHook {
  name = "cargo-zstd-sys";

  propagatedBuildInputs = [
    pkgs.pkgsBuildHost.pkg-config
    zstd
  ];
}
