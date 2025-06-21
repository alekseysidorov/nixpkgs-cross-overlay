{ mkEnvHook
, pkgs
, zstd
, cargoDeps
}:

mkEnvHook {
  name = "zstd-sys";

  propagatedBuildInputs = [
    pkgs.pkgsBuildHost.pkg-config
    cargoDeps.bindgen
  ];
  depsTargetTargetPropagated = [
    zstd
  ];
}
