final: prev: {
  gitAndTools = prev.gitAndTools // {
    pass-git-helper = final.python3Packages.callPackage ../pkgs/pass-git-helper { };
  };
  masterpdfeditor-free = final.callPackage ../pkgs/masterpdfeditor-free { };
  mathematica-firejail = final.callPackage ../pkgs/mathematica-firejail { };
  nix-direnv = prev.nix-direnv.override { nix = final.nixFlakes; };
  nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
  pop-os-shell = final.callPackage ../pkgs/pop-os-shell { };
  softmaker-office = prev.softmaker-office.override {
    officeVersion = {
      version = "976";
      edition = "2018";
      sha256 = "sha256-A45q/irWxKTLszyd7Rv56WeqkwHtWg4zY9YVxqA/KmQ=";
    };
  };
  splatmoji = final.callPackage ../pkgs/splatmoji { };
}
