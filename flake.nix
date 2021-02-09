{
  description = "NixOS modules";

  outputs = { self, ... }: {
    overlays = {
      system = final: prev: {
        adblock = final.callPackage ./adblock { };
        drone-runner-docker = final.callPackage ./drone-runner-docker { };
      };
      user = final: prev: {
        gnuplot-git = final.callPackage ./gnuplot-git { };
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
