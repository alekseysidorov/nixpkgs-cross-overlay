{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-cross-overlay = {
      url = "github:alekseysidorov/nixpkgs-cross-overlay/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { ... }: { };
}
