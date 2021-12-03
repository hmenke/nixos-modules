final: prev: {
  masterpdfeditor-free = final.callPackage ../pkgs/masterpdfeditor-free { };
  mathematica-env = final.callPackage ../pkgs/mathematica-env { };
  nix-direnv = prev.nix-direnv.override { enableFlakes = true; };
  nix-prefetch = prev.nix-prefetch.override { nix = final.nixFlakes; };
  nix-update = prev.nix-update.override { nix = final.nixFlakes; };
  nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
  nixpkgs-review = prev.nixpkgs-review.override { nix = final.nixFlakes; };
  pop-os-shell = final.callPackage ../pkgs/pop-os-shell { };
  softmaker-office-2018-976 = final.softmaker-office.override {
    officeVersion = {
      version = "976";
      edition = "2018";
      hash = "sha256-A45q/irWxKTLszyd7Rv56WeqkwHtWg4zY9YVxqA/KmQ=";
    };
  };
  texlive-env = final.callPackage ../pkgs/texlive-env { };
}
