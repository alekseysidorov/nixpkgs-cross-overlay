{ mkEnvHook
, pkgs
, libopus
}:

mkEnvHook {
  name = "cargo-audiopus_sys";

  propagatedBuildInputs = with pkgs.pkgsBuildHost; [
    pkg-config
    cmake
  ];
  depsTargetTargetPropagated = [
    libopus
  ];
}
