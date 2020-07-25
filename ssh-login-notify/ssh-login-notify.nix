{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.openssh.loginNotify;

  sendmail = pkgs.writeScript "ssh-loginNotify"
    ''
      #!${pkgs.runtimeShell}
      
      # Only notify for login session
      SESSION_TYPES=(${toString cfg.sessionTypes})
      if ! printf "%s\n" ''${SESSION_TYPES[@]} | grep -qxF "$PAM_TYPE"; then
      	exit 0
      fi
      
      # Don't notify for git (too noisy)
      EXCLUDED_USERS=(${toString cfg.excludeUsers})
      if printf "%s\n" ''${EXCLUDED_USERS[@]} | grep -qxF "$PAM_USER"; then
      	exit 0
      fi
      
      ${pkgs.system-sendmail}/bin/sendmail -t <<EOF
      To: ${cfg.mailTo}
      From: ${cfg.mailFrom}
      Subject: SSH login: $PAM_USER from $PAM_RHOST on $(hostname)
      Content-Type: text/plain; charset="utf-8"
      
      User: $PAM_USER
      Remote Host: $PAM_RHOST
      Service: $PAM_SERVICE
      TTY: $PAM_TTY
      Date: $(date -u)
      Server: $(uname -a)
      Environment:
      $(env)
      EOF
    '';

in

{

  ###### interface

  options = {
    services.openssh.loginNotify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable email notification on SSH login.";
      };

      mailTo = mkOption {
        type = types.str;
        default = null;
        description = "Email address to which the login notification will be mailed.";
      };

      mailFrom = mkOption {
        type = types.str;
        default = null;
        description = "Email address from which the login notification will be mailed.";
      };

      sessionTypes = mkOption {
        type = types.listOf types.str;
        default = [ "open_session" ];
        description = "Session types for which to send a notification.";
      };

      excludeUsers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Users to exclude from login notification.";
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = cfg.mailTo != null && cfg.mailFrom != null;
      message = "You need to specify a sender and a receiver";
    };

    security.pam.services."sshd".text = lib.mkDefault ''
      # email alert on SSH login
      session required pam_exec.so ${sendmail}
    '';
  };

}
