{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.extensions.systemd.notifySend;
in {
  options = {
    extensions.systemd.notifySend = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether to enable desktop notification for failed services.";
      };

      user = mkOption {
        type = types.str;
        default = null;
        description =
          "User session to which the notification will be sent.";
      };
    };

    systemd.services = mkOption {
      type = with types;
        attrsOf (submodule {
          config.onFailure = optional cfg.enable "notify-send@%n.service";
        });
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = cfg.user != null;
      message = "You need to specify a user";
    };

    systemd.services."notify-send@" = {
      description = "Desktop notification for %i";
      onFailure = lib.mkForce [ ];
      environment = {
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${toString config.users.users.${cfg.user}.uid}/bus";
        INSTANCE = "%i";
      };
      script = ''
        ${pkgs.libnotify}/bin/notify-send --urgency=critical \
          "Service '$INSTANCE' failed" \
          "$(journalctl -n 6 -o cat -u $INSTANCE)"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
      };
    };
  };

}
