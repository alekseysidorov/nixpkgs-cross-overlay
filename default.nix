final: prev: {
  # Applies some patches on the nix packages to better cross-compilation support.
  #
  # deprecated: use `nixpgs` directly.
  mkCrossPkgs =
    { src
    , localSystem
    , crossSystem ? null
    , config ? { }
    , overlays ? [ ]
    }:

    let
      crossOverlay = import ./.;
    in
    import src {
      inherit localSystem crossSystem config;
      overlays = [ crossOverlay ] ++ overlays;
    };
} // (import ./lib final prev)
