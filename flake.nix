{
  description = "Rust cross-compilatilon utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , rust-overlay
    , flake-utils
    , treefmt-nix
    }: flake-utils.lib.eachDefaultSystem
      (system:
      let
        # Setup nixpkgs.
        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            (import rust-overlay)
          ];
        };
        treefmt = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;

        # List of supported cross systems 
        supportedCrossSystems = [
          { config = "x86_64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }
          { config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = false; }
          { config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = false; }
          { config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = true; }
          { config = "x86_64-unknown-linux-musl"; useLLVM = false; isStatic = false; }
          { config = "aarch64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }
          { config = "aarch64-unknown-linux-musl"; useLLVM = true; isStatic = false; }
          { config = "aarch64-unknown-linux-musl"; useLLVM = true; isStatic = true; }
          { config = "aarch64-unknown-linux-musl"; useLLVM = false; isStatic = false; }
          { config = "riscv64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }
        ];

        mkDevShellName = crossSystem:
          let
            compiler = if crossSystem.useLLVM then "llvm" else "gcc";
            ty = if crossSystem.isStatic then "static" else "dymanic";
          in
          "cross/${crossSystem.config}/${compiler}/${ty}";

        mkDevShells = pkgs.lib.lists.foldr
          (crossSystem: output:
            output // {
              "${mkDevShellName crossSystem}" = import ./shell.nix {
                localSystem = system;
                inherit crossSystem;
              };
            })
          {
            default = import ./shell.nix {
              localSystem = system;
            };
          };
      in
      rec
      {
        # for `nix fmt`
        formatter = treefmt.wrapper;
        # for `nix flake check`
        checks.formatting = treefmt.check self;

        devShells = mkDevShells supportedCrossSystems;

        packages.pushAll = with pkgs; writeShellApplication {
          name = "pushAll";
          runtimeInputs = [ cachix ];

          text = pkgs.lib.attrsets.foldlAttrs
            (output: name: drv:
              ''
                cachix push nixpkgs-cross-overlay ${drv}
                echo "-> Pushed artifacts of ${name} to cachix"
              ''
              + output)
            ""
            devShells;
        };
      })
    # System independent modules.
    // {
      # The usual flake attributes can be defined here, including system-
      # agnostic ones like nixosModule and system-enumerating ones, although
      # those are more easily expressed in perSystem.
      overlays =
        let
          nixpkgs-cross-overlay = import ./.;
          rust-overlay' = (import rust-overlay);
        in
        {
          default = nixpkgs-cross-overlay;
          rust-overlay = rust-overlay';
          # Export as a flake overlay including all dependent overlays.
          full = final: prev:
            (rust-overlay' final prev) // (nixpkgs-cross-overlay final prev);
        };
    };
}
