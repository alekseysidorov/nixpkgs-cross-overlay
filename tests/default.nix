{ localSystem
, crossSystems
, pkgs
, src
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
    [ ];

  # List of well-known packages that are buildable with this overlay.
  supportedPkgs = with pkgs; [
    icu
    coreutils
    bashInteractive
    toml11
    nano
  ] ++ lib.optionals (!stdenv.targetPlatform.isMusl) [
    msgpack-cxx
    boost178
  ];
in
pkgs.writeShellApplication {
  name = "build-cross-systems";

  runtimeInputs = supportedPkgs ++
    (forEachCrossSystem
      (pkgs:
        [
          (pkgs.callPackage ./crates { })
          (pkgs.callPackage ./dockerImage.nix { })
        ]
      )
      targets);

  text = '''';
}
