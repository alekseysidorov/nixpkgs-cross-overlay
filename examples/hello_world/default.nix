# An example of a local cross-compilation without `flakes`.
{ config ? "x86_64-unknown-linux-musl"
, isStatic ? false
}:

let
  system = builtins.currentSystem;
  crossSystem = { inherit config isStatic; };

  lockFile = import ./../../utils/flake-lock.nix { src = ./.; };

  mkCrossPkgs = (import lockFile.nixpkgs {
    system = builtins.currentSystem;
    overlays = [
      (import lockFile.nixpkgs-cross-overlay)
    ];
  }).mkCrossPkgs;

  pkgs = mkCrossPkgs {
    inherit system crossSystem;
    src = lockFile.nixpkgs;
  };
in
rec {
  shell = pkgs.stdenv.mkDerivation {
    name = "shell-cross";
    strictDeps = true;
    nativeBuildInputs = [ pkgs.rustCrossHook ];
    propagatedBuildInputs = [ pkgs.openssl.dev ];
  };

  dockerImage = pkgs.dockerTools.buildLayeredImage {
    name = "hello_world";
    tag = crossSystem.config + (if isStatic then "-static" else "");

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
  };
}
