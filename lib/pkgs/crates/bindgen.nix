{ mkEnvHook
, stdenv
, pkgs
}:
mkEnvHook {
  name = "bindgen";

  propagatedBuildInputs = [
    pkgs.pkgsBuildHost.rustPlatform.bindgenHook
    stdenv.cc.libc
  ];
}
