{ mkEnvHook
, pkgs
, libopus
}:

mkEnvHook {
  name = "audiopus_sys";

  propagatedBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    cmake
  ];
  depsTargetTargetPropagated = [
    libopus
  ];
}
