{ mkEnvHook
, stdenv
, pkgs
}:
mkEnvHook {
  name = "bindgen";

  propagatedBuildInputs = [
    pkgs.pkgsBuildHost.rustPlatform.bindgenHook
  ];
  depsTargetTargetPropagated = [
    stdenv.cc.libc_dev
  ];
}
