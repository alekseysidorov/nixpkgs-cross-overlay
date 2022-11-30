{ ... } @crossSystem:

let
  pkgs = import ./. crossSystem;
in

pkgs.mkShell {
  name = "shell-cross";
  nativeBuildInputs = [ pkgs.rustCrossHook ];
  propagatedBuildInputs = [ pkgs.openssl.dev ];
}
