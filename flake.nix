{
  description = "NixOS modules";

  outputs = { self, ... }: {
    overlays = {
      system = final: prev: {
        adblock = final.callPackage ./pkgs/adblock { };
        drone-runner-docker = final.callPackage ./pkgs/drone-runner-docker { };
      };
      user = final: prev: {
        gitAndTools = prev.gitAndTools // {
          diff-highlight = final.callPackage ./pkgs/diff-highlight { };
          pass-git-helper = final.python3Packages.callPackage ./pkgs/pass-git-helper { };
        };
        gnuplot-git = final.callPackage ./pkgs/gnuplot-git { };
        masterpdfeditor-free = final.callPackage ./pkgs/masterpdfeditor-free { };
        mathematica-firejail = final.callPackage ./pkgs/mathematica-firejail { };
        nix-direnv = prev.nix-direnv.override { nix = final.nixFlakes; };
        nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
        softmaker-office = prev.softmaker-office.override {
          officeVersion = {
            version = "976";
            edition = "2018";
            sha256 = "sha256:14qnlbczq1zcz24vwy2yprdvhyn6bxv1nc1w6vjyq8w5jlwqsgbr";
          };
        };
        splatmoji = final.callPackage ./pkgs/splatmoji { };
      };
    };

    nixosModules = {
      adblock = import ./modules/adblock/module.nix;
      deployment = import ./modules/deployment/module.nix;
      drone-runner-docker = import ./modules/drone-runner-docker/module.nix;
      nginx-stream-ssl-preread = import ./modules/nginx-stream-ssl-preread/module.nix;
      ssh-login-notify = import ./modules/ssh-login-notify/module.nix;
      systemd-boot = import ./modules/systemd-boot/systemd-boot.nix;
      systemd-email-notify = import ./modules/systemd-email-notify/module.nix;
      wstunnel = import ./modules/wstunnel/module.nix;
    };
  };
}
