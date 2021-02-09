{
  description = "NixOS modules";

  outputs = { self, ... }: {
    overlays = {
      system = final: prev: {
        adblock = final.callPackage ./adblock { };
        drone-runner-docker = final.callPackage ./drone-runner-docker { };
      };
      user = final: prev: {
        gitAndTools = prev.gitAndTools // {
          diff-highlight = final.callPackage ./diff-highlight { };
          pass-git-helper = final.python3Packages.callPackage ./pass-git-helper { };
        };
        gnuplot-git = final.callPackage ./gnuplot-git { };
        masterpdfeditor-free = final.callPackage ./masterpdfeditor-free { };
        mathematica-firejail = final.callPackage ./mathematica-firejail { };
        nix-direnv = prev.nix-direnv.override { nix = final.nixFlakes; };
        nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
        softmaker-office = prev.softmaker-office.override {
          officeVersion = {
            version = "976";
            edition = "2018";
            sha256 = "sha256:14qnlbczq1zcz24vwy2yprdvhyn6bxv1nc1w6vjyq8w5jlwqsgbr";
          };
        };
        splatmoji = final.callPackage ./splatmoji { };
      };
    };

    nixosModules = {
      adblock = import ./adblock/module.nix;
      deployment = import ./deployment/module.nix;
      drone-runner-docker = import ./drone-runner-docker/module.nix;
      nginx-stream-ssl-preread = import ./nginx-stream-ssl-preread/module.nix;
      ssh-login-notify = import ./ssh-login-notify/module.nix;
      systemd-boot = import ./systemd-boot/systemd-boot.nix;
      systemd-email-notify = import ./systemd-email-notify/module.nix;
      wstunnel = import ./wstunnel/module.nix;
    };
  };
}
