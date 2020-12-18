{
  imports = [
    ./adblock/module.nix
    ./declarative-channels/module.nix
    ./nginx-stream-ssl-preread/module.nix
    ./ssh-login-notify/module.nix
    ./systemd-boot/systemd-boot.nix
    ./systemd-email-notify/module.nix
    ./wstunnel/module.nix
  ];

  nixpkgs.overlays = [ (final: prev: {
    adblock = final.callPackage ./adblock {};
    drone-runner-docker = final.callPackage ./drone-runner-docker { };
  }) ];
}
