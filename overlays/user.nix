final: prev: {
  gitAndTools = prev.gitAndTools // {
    diff-highlight = final.callPackage ../pkgs/diff-highlight { };
    pass-git-helper = final.python3Packages.callPackage ../pkgs/pass-git-helper { };
  };
  gnuplot-git = final.callPackage ../pkgs/gnuplot-git { };
  masterpdfeditor-free = final.callPackage ../pkgs/masterpdfeditor-free { };
  mathematica-firejail = final.callPackage ../pkgs/mathematica-firejail { };
  nix-direnv = prev.nix-direnv.override { nix = final.nixFlakes; };
  nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
  softmaker-office = prev.softmaker-office.override {
    officeVersion = {
      version = "976";
      edition = "2018";
      sha256 = "sha256:14qnlbczq1zcz24vwy2yprdvhyn6bxv1nc1w6vjyq8w5jlwqsgbr";
    };
  };
  splatmoji = final.callPackage ../pkgs/splatmoji { };
}
