{
  imports = [
    ./declarative-channels/channels.nix
    ./ssh-login-notify/ssh-login-notify.nix
    ./systemd-boot/systemd-boot.nix
    ./systemd-email-notify/systemd-email-notify.nix
    ./wstunnel/tunnel.nix
  ];
}
