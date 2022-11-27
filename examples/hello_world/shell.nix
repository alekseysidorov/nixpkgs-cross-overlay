{ config ? "x86_64-unknown-linux-musl"
, isStatic ? false
}:

let
  pkgs = import ./. { inherit config isStatic; };
in

pkgs.mkShell {
  name = "shell-cross";
  nativeBuildInputs = [ pkgs.rustCrossHook ];
  propagatedBuildInputs = [ pkgs.openssl.dev ];
}
