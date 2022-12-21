{ ... } @crossSystem:

let
  pkgs = import ./. crossSystem;
in

pkgs.mkShell {
  name = "shell-cross";
  nativeBuildInputs = [ pkgs.rustCrossHook pkgs.pkgsBuildHost.pkg-config ];
  propagatedBuildInputs = [ pkgs.cargoDeps.rdkafka-sys pkgs.zstd pkgs.lz4 ];
}
