{ mkEnvHook
, pkgs
, zstd
, openssl
}:

mkEnvHook {
  name = "cargo-openssl-sys";

  propagatedBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    perl
  ];
  depsTargetTargetPropagated = [
    openssl.dev
  ];
}
