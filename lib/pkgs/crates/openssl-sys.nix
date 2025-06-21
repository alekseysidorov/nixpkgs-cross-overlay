{ mkEnvHook
, pkgs
, openssl
}:

mkEnvHook {
  name = "openssl-sys";

  propagatedBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    perl
  ];
  depsTargetTargetPropagated = [
    openssl.dev
  ];
}
