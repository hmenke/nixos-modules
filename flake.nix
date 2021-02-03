{
  description = "NixOS modules";

  outputs = { self, nixpkgs, ... }: {
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

    packages.x86_64-linux =
      with nixpkgs.legacyPackages.x86_64-linux;
      {
        adblock = callPackage ./adblock { };
        drone-runner-docker = callPackage ./drone-runner-docker { };
      };
  };
}
