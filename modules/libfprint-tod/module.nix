{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.fprintd;

in

{
  disabledModules = [ "services/security/fprintd.nix" ];

  ###### interface

  options = {

    services.fprintd = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable fprintd daemon and PAM module for fingerprint readers handling.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.fprintd.override {
          libfprint = pkgs.libfprint-tod;
        };
        defaultText = "pkgs.fprintd";
        description = ''
          fprintd package to use.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    nixpkgs.overlays = [ (final: prev: {
      libfprint-tod = final.callPackage ../../pkgs/libfprint-tod/default.nix { };
      libfprint-tod-goodix = final.callPackage ../../pkgs/libfprint-tod-goodix/default.nix { };
    }) ];

    services.dbus.packages = [ cfg.package ];

    services.udev.packages = [
      pkgs.libfprint-tod
      pkgs.libfprint-tod-goodix
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.packages = [ cfg.package ];
    systemd.services."fprintd".environment = {
      "G_MESSAGES_DEBUG" = "all";
      "FP_TOD_DRIVERS_DIR" = "${pkgs.libfprint-tod-goodix}/lib/libfprint-2/tod-1";
    };

  };

}
