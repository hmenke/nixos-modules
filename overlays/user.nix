final: prev: {
  gajim = prev.gajim.overrideAttrs ({ buildInputs, ... }: {
    buildInputs = buildInputs ++ [ final.libappindicator-gtk3 ];
  });
  masterpdfeditor-free = final.callPackage ../pkgs/masterpdfeditor-free { };
  mathematica-env = final.callPackage ../pkgs/mathematica-env { };
  nix-direnv = prev.nix-direnv.override { enableFlakes = true; };
  nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
  pop-os-shell = final.callPackage ../pkgs/pop-os-shell { };
  softmaker-office-2018-976 = final.softmaker-office.override {
    officeVersion = {
      version = "976";
      edition = "2018";
      hash = "sha256-A45q/irWxKTLszyd7Rv56WeqkwHtWg4zY9YVxqA/KmQ=";
    };
  };
  splatmoji = final.callPackage ../pkgs/splatmoji { };
  texlive-env = final.callPackage ../pkgs/texlive-env { };
}
