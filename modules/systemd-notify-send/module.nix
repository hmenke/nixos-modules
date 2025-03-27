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
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = cfg.user != null;
      message = "You need to specify a user";
    };

    systemd.packages = [
      (pkgs.runCommandNoCC "toplevel-override.conf" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } ''
        mkdir -p $out/etc/systemd/system/service.d/
        cat <<-'EOF' > $out/etc/systemd/system/service.d/toplevel-override.conf
        [Unit]
        OnFailure=notify-send@%n.service
        EOF
      '')
    ];

    systemd.services."notify-send@" = {
      description = "Desktop notification for %i";
      onFailure = lib.mkForce [ ];
      environment = {
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/${toString config.users.users.${cfg.user}.uid}/bus";
        INSTANCE = "%i";
      };
      script = ''
        ${pkgs.libnotify}/bin/notify-send --app-name="$INSTANCE" --urgency=critical \
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
