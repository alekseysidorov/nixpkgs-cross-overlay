# treefmt.nix
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs.nixpkgs-fmt.enable = true;
  programs.rustfmt = {
    enable = true;
    package = pkgs.rust-bin.nightly.latest.default;
  };
  programs.beautysh.enable = true;
  programs.deno.enable = true;
  programs.taplo.enable = true;
}
