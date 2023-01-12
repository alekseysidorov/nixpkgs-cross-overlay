{ ... } @crossSystem:

let
  pkgs = import ./. crossSystem;
in

pkgs.mkShell {
  name = "shell-cross";
  nativeBuildInputs = [
    pkgs.rustBuildHostDependencies
    pkgs.rustCrossHook
    pkgs.pkgsBuildHost.pkg-config
  ];
  buildInputs = [ pkgs.rdkafka pkgs.cargoDeps.rdkafka-sys ];
  propagatedBuildInputs = [ pkgs.rdkafka ];
}
