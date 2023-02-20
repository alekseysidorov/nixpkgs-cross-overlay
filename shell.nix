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
    # Setup Rust overlay
    (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
    # Native utilities
    cmake
    pkg-config
    protobuf
    git
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
    # Linters
    nixpkgs-fmt
    dprint
  ]
  # Build also all cargo deps.
  ++ cargoDeps.all;

  buildInputs = with pkgs; [
    # List of tested native libraries.
    rdkafka
    rocksdb
    libopus
    icu
    bash
    bashInteractive
    coreutils
    # Enable cross-compilation support.
    rustCrossHook
  ];

  shellHook = "${pkgs.crossBashPrompt}";

  # Make it buildable, to make it possible to upload it to cache
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    echo "''${buildInputs}"        > $out/inputs.txt
  '';
}
