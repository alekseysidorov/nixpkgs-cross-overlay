{ config ? "x86_64-unknown-linux-musl"
, isStatic ? false
}:

let
  pkgs = import ./. { inherit config isStatic; };
  shell = import ./shell.nix { inherit config isStatic; };
in
pkgs.dockerTools.buildLayeredImage {
  name = "hello_world";
  tag = config + (if isStatic then "-static" else "");

  contents = [
    shell.propagatedBuildInputs
    (pkgs.copyBinaryFromCargoBuild {
      name = "hello_world";
      targetDir = ./target;
    })
  ];

  config = {
    EntryPoint = [ "hello_world" ];
    WorkingDir = "/";
    Env = [
      "PATH=/bin"
    ];
  };
}
