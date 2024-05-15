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
    # Setup rust
    (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
    # Will add some dependencies like libiconv
    rustBuildHostDependencies
    # Linters
    nixpkgs-fmt
    shellcheck
    # Useful utilites
    ldproxy
  ]
  # Build also all cargo deps
  ++ pkgs.cargoDeps.all;

  buildInputs = with pkgs; [
    # Enable Rust cross-compilation support
    rustCrossHook
    # List of tested native libraries
    icu
  ];

  shellHook = "${pkgs.crossBashPrompt}";

  # Minimal shell for partialy supported targets.
  passthru.minimalShell = pkgs.mkShell {
    nativeBuildInputs = with pkgs.pkgsBuildHost; [
      # Setup rust
      (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
      # Will add some dependencies like libiconv
      rustBuildHostDependencies
    ];

    buildInputs = with pkgs; [
      # Enable Rust cross-compilation support
      rustCrossHook
    ];

    shellHook = "${pkgs.crossBashPrompt}";
  };
}
