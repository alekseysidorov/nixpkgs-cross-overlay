final: prev: {
  # Applies some patches on the nix packages to better cross-compilation support.
  mkCrossPkgs =
    {
      # Nixpkgs sources snapshot
      src
    , localSystem
    , crossSystem ? null
    , overlays ? [ ]
      # Don't apply any patches to the nixpkgs snapshot referred to in the `src` argument
    , useVanilla ? false
    }:
    let
      localPkgs = import src { inherit localSystem; };
      stdenv = localPkgs.stdenv;

      patchedPkgs = localPkgs.applyPatches {
        name = "patched-pkgs";
        inherit src;
        # Fix musl permissions on Darwin hosts.
        patches = [
          ./patches/gcc-darwin-permissions-fix.patch
        ];
      };

      nixpkgs =
        if !useVanilla && stdenv.isDarwin && crossSystem != null
        then patchedPkgs
        else src;

      crossOverlay = import ./.;
    in
    import nixpkgs {
      inherit localSystem crossSystem;
      overlays = [ crossOverlay ] ++ overlays;
    };
} // (import ./lib final prev)
