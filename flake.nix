{
  description = "Rust cross-compilatilon utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
        overlays =
          let
            nixpkgs-cross-overlay = import ./.;
            rust-overlay' = import inputs.rust-overlay;
          in
          {
            inherit nixpkgs-cross-overlay;
            rust-overlay = rust-overlay';
            # Export as a flake overlay including all dependent overlays.
            default = final: prev:
              (rust-overlay' final prev)
              // (nixpkgs-cross-overlay final prev);
          };
      };

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        devShells = {
          default = import ./shell.nix { localSystem = system; };
          # Example cross shell.
          example-cross = import ./shell.nix {
            localSystem = system;
            crossSystem = { config = "x86_64-unknown-linux-musl"; useLLVM = true; };
          };
        };

        treefmt.config = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
          programs.rustfmt.enable = true;
          programs.beautysh.enable = true;
          programs.deno.enable = true;
        };

        formatter = config.treefmt.build.wrapper;
      };
    };
}
