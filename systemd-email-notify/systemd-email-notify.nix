{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.extensions.systemd.emailNotify;

  sendmail = pkgs.writeScript "systemd-email-notify" ''
    #!${pkgs.runtimeShell}

    ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
    To: ${cfg.mailTo}
    From: ${cfg.mailFrom}
    Subject: [${config.networking.hostName}] Status of service $1
    Content-Transfer-Encoding: 8bit
    Content-Type: text/plain; charset=UTF-8

    === Current status of unit "$1" ===

    $(${config.systemd.package}/bin/systemctl status --full "$1")

    === Journal of unit "$1" for the current boot ===

    $(${config.systemd.package}/bin/journalctl -b -0 -u "$1")
    ERRMAIL
  '';

in {
  options = {
    extensions.systemd.emailNotify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether to enable email notification for failed services.";
      };

      mailTo = mkOption {
        type = types.str;
        default = null;
        description =
          "Email address to which the service status will be mailed.";
      };

      mailFrom = mkOption {
        type = types.str;
        default = null;
        description =
          "Email address from which the service status will be mailed.";
      };
    };

    systemd.services = mkOption {
      type = with types;
        attrsOf (submodule {
          config.onFailure = optional cfg.enable "email@%n.service";
        });
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = cfg.mailTo != null && cfg.mailFrom != null;
      message = "You need to specify a sender and a receiver";
    };

    systemd.services."email@" = {
      description = "Sends a status mail via sendmail on service failures.";
      onFailure = mkForce [ ];
      serviceConfig = {
        ExecStart = "${sendmail} %i";
        Type = "oneshot";
      };
    };
  };

}
