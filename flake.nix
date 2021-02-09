{
  description = "NixOS modules";

  outputs = { self, ... }: {
    overlays = {
      system = import ./overlays/system;
      user = import ./overlay/user;
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
