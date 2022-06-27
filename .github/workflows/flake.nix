{
  description = "Binary cache";

  inputs = {
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-branchless = {
      url = "github:arxanas/git-branchless";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, emacs-overlay, git-branchless, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          emacs-overlay.overlay
          git-branchless.overlay
        ];
      };
    in {
      checks.${system} = { inherit (pkgs) emacsPgtkGcc; };
  };
}
