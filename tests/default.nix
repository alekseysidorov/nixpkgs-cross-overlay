{ localSystem
, crossSystems
, pkgs
, src
,
}:
let
  targets = builtins.map
    (
      crossSystem: pkgs.mkCrossPkgs {
        inherit src localSystem crossSystem;
        overlays = pkgs.overlays;
      }
    )
    crossSystems;

  forEachCrossSystem = f: pkgs.lib.lists.foldr
    (pkgsCross: inputs: (f pkgsCross) ++ inputs)
    [ ]
    targets;
in
pkgs.writeShellApplication {
  name = "build-cross-systems";

  runtimeInputs = forEachCrossSystem (pkgsCross: [
    (pkgsCross.callPackage ./crates { })
  ]);
  text = ''
  '';
}
