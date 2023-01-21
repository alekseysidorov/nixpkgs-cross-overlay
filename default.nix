final: prev:

{
  # Applies some patches on the nix packages to better cross-compilation support.
  mkCrossPkgs =
    { src
    , localSystem
    , crossSystem ? null
    , overlays ? [ ]
    }:
    let
      localPkgs = import src { inherit localSystem; };
      stdenv = localPkgs.stdenv;
      # Create fake cross packages to query target platform.
      fakeCrossPkgs = import src { inherit localSystem crossSystem; };

      patchedPkgs = localPkgs.applyPatches {
        name = "patched-pkgs";
        inherit src;
        # Fix musl gcc permissions on M1 Mac.
        patches = [
          ./patches/gcc-darwin-permissions-fix.patch
        ];
      };

      nixpkgs =
        if stdenv.isDarwin && fakeCrossPkgs.stdenv.targetPlatform.isx86_64
        then patchedPkgs
        else src;

      crossOverlay = import ./.;
    in
    import nixpkgs {
      inherit localSystem crossSystem;
      overlays = [ crossOverlay ] ++ overlays;
    };
}
  // (import ./pkgs/all-packages.nix final prev)
