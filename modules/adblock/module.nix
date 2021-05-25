{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.extensions.adblock;

in {

  ###### interface

  options = {

    extensions.adblock = {

      enable = mkOption {
        type = types.bool;
        default = false;
      };

      alternative = mkOption {
        type = types.str;
        default = "hosts";
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable (let

    hosts = pkgs.adblock.override { inherit (cfg) alternative; };

  in {
    nixpkgs.overlays = [ (final: prev: {
      adblock = final.callPackage ../../pkgs/adblock/default.nix { };
    }) ];

    networking.hostFiles = [ "${hosts}/etc/hosts" ];

    services.unbound.settings.server.include = "${hosts}/etc/unbound/adblock.conf";

  });

}
