{
  description = "NixOS modules";

  outputs = { self, ... }: {
    overlays = {
      system = import ./overlays/system.nix;
      user = import ./overlays/user.nix;
    };

    nixosModules = {
      adblock = import ./modules/adblock/module.nix;
      deployment = import ./modules/deployment/module.nix;
      ssh-login-notify = import ./modules/ssh-login-notify/module.nix;
      systemd-boot = import ./modules/systemd-boot/systemd-boot.nix;
      systemd-email-notify = import ./modules/systemd-email-notify/module.nix;
      wstunnel = import ./modules/wstunnel/module.nix;
      zfs-auto-snapshot = import ./modules/zfs-auto-snapshot/module.nix;
    };
  };
}
