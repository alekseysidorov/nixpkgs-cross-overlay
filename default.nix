final: prev: {
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

      patchedPkgs = localPkgs.applyPatches {
        name = "patched-pkgs";
        inherit src;
        # Fix musl permissions on Darwin hosts.
        patches = [
          ./patches/gcc-darwin-permissions-fix.patch
        ];
      };

      nixpkgs =
        if (stdenv.isDarwin && crossSystem != null)
        then patchedPkgs
        else src;

      crossOverlay = import ./.;
    in
    import nixpkgs {
      inherit localSystem crossSystem;
      overlays = [ crossOverlay ] ++ overlays;
      config.packageOverrides = pkgs: {
        # HACK: Don't use antique LLVM 11
        llvmPackages = pkgs.llvmPackages_latest;
      };
    };
} // (import ./lib final prev)
