{
  description = "NixOS modules";

  outputs = { self, ... }: {
    overlays = {
      system = import ./overlays/system.nix;
    };

    nixosModules = {
      adblock = import ./modules/adblock/module.nix;
      ssh-login-notify = import ./modules/ssh-login-notify/module.nix;
      systemd-email-notify = import ./modules/systemd-email-notify/module.nix;
      systemd-notify-send = import ./modules/systemd-notify-send/module.nix;
      zfs-auto-snapshot = import ./modules/zfs-auto-snapshot/module.nix;
    };
  };
}
