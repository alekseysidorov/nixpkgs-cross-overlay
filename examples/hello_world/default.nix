# An example of a local cross-compilation without `flakes`.
{ config ? "x86_64-unknown-linux-musl" }:

let
  system = builtins.currentSystem;
  crossSystem = { inherit config; };

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

  copyCargoBin = name:
    let
      cargo-target = pkgs.stdenv.targetPlatform.config;
      cargo-binary-path = ./target + "/${cargo-target}/release/${name}";
    in
    pkgs.runCommand
      "copy-${name}-bin"
      { buildInputs = [ ]; }
      ''
        mkdir -p $out/bin
        cp ${cargo-binary-path} $out/bin/${name}
        chmod +x $out/bin/${name}
      '';
in
{
  shell = pkgs.stdenv.mkDerivation {
    name = "shell-cross";
    strictDeps = true;
    nativeBuildInputs = [ pkgs.rustCrossHook ];
  };

  dockerImage = pkgs.dockerTools.buildLayeredImage {
    name = "hello_world";
    tag = crossSystem.config;

    contents = [
      pkgs.bashInteractive
      pkgs.cacert
      pkgs.openssl.dev
      pkgs.coreutils
      (copyCargoBin "hello_world")
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
