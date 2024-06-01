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
          ''null''
          ''{ config = "x86_64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }''
          ''{ config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = false; }''
          ''{ config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = false; }''
          ''{ config = "x86_64-unknown-linux-musl"; useLLVM = true; isStatic = true; }''
          ''{ config = "x86_64-unknown-linux-musl"; useLLVM = false; isStatic = false; }''
          ''{ config = "aarch64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }''
          ''{ config = "aarch64-unknown-linux-musl"; useLLVM = true; isStatic = false; }''
          ''{ config = "aarch64-unknown-linux-musl"; useLLVM = true; isStatic = true; }''
          ''{ config = "aarch64-unknown-linux-musl"; useLLVM = false; isStatic = false; }''
          ''{ config = "riscv64-unknown-linux-gnu"; useLLVM = false; isStatic = false; }''
        ];
      in
      {
        # for `nix fmt`
        formatter = treefmt.wrapper;
        # for `nix flake check`
        checks.formatting = treefmt.check self;

        devShells = {
          default = import ./shell.nix { localSystem = system; };

          # Example cross shells
          example-cross = import ./shell.nix {
            localSystem = system;
            crossSystem = { config = "x86_64-unknown-linux-musl"; useLLVM = true; };
          };

          example-cross-gnu = import ./shell.nix {
            localSystem = system;
            crossSystem = { config = "x86_64-unknown-linux-gnu"; };
          };
        };

        packages = rec {
          build-cross-system = pkgs.writeShellApplication {
            name = "build-cross-system";
            runtimeInputs = with pkgs; [ nix ];
            text = ''
              CROSS_SYSTEM="''${1:-null}"

              echo "-> Compiling '$CROSS_SYSTEM' cross system" >&2
              BUILD_OUTPUT=$(nix-build shell.nix -A inputDerivation --arg crossSystem "$CROSS_SYSTEM")

              echo "-> Performing '$CROSS_SYSTEM' testing" >&2
              nix-shell --pure --arg crossSystem "$CROSS_SYSTEM" --run ./tests/crates/build_all.sh
              echo "$BUILD_OUTPUT"
            '';
          };

          push-all = with pkgs; writeShellApplication {
            name = "push-all";
            runtimeInputs = [ nix build-cross-system ];
            text =
              let
                push-all = lib.lists.foldr
                  (crossSystem: output:
                    let
                      cmd = ''
                        # Compile '${crossSystem}'
                        BUILD_OUTPUT=$(build-cross-system '${crossSystem}')
                        echo "-> Pushing artifacts to the Cachix"
                        cachix push nixpkgs-cross-overlay "$BUILD_OUTPUT"

                      '';
                    in
                    cmd + output)
                  "";
              in
              push-all supportedCrossSystems;
          };
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
