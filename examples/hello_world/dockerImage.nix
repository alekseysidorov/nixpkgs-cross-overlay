{ isStatic ? false
, ...
} @crossSystem:

let
  pkgs = import ./. crossSystem;
  shell = import ./shell.nix crossSystem;
in
pkgs.dockerTools.buildLayeredImage {
  name = "hello_world";
  tag = crossSystem.config + (if isStatic then "-static" else "");

  contents = [
    shell.propagatedBuildInputs
    pkgs.bashInteractive
    pkgs.coreutils
    pkgs.stdenv.cc.libc_bin
    (pkgs.copyBinaryFromCargoBuild {
      name = "hello_world";
      targetDir = ./target;
    })
  ];

  config = {
    Cmd = [ "hello_world" ];
    WorkingDir = "/";
    Env = [
      "PATH=/bin"
    ];
  };
}
