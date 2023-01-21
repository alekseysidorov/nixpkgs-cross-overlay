{
  description = "Rust cross-compilatilon utils";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = import ./.;
  } // flake-utils.lib.eachDefaultSystem
    (localSystem:
      {
        devShells = {
          default = import ./shell.nix { inherit localSystem; };
          x86_64-unknown-linux-musl = import ./shell.nix {
            inherit localSystem;
            crossSystem = {
              config = "x86_64-unknown-linux-musl";
              useLLVM = true;
            };
          };
        };

        overlays = {
          default = import ./.;
        };
      }
    );
}
