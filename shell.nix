{ localSystem ? builtins.currentSystem
, crossSystem ? null
}:
let
  pkgs = import ./utils/nixpkgs.nix {
    inherit localSystem crossSystem;
  };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs.pkgsBuildHost; [
    # Native utilities
    protobuf
    # Setup Rust overlay
    (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
    # Linters
    nixpkgs-fmt
    dprint
  ]
  # Build also all cargo deps.
  ++ pkgs.cargoDeps.all;

  buildInputs = with pkgs; [
    # Enable Rust cross-compilation support.
    rustCrossHook
    # List of tested native libraries.
    icu
    bash
    bashInteractive
    coreutils
  ];

  shellHook = "${pkgs.crossBashPrompt}";

  # Make it buildable, to make it possible to upload it to cache
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    echo "''${buildInputs}"        > $out/inputs.txt
  '';
}
