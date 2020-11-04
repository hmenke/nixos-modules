{ config, lib, pkgs, ... }:

with lib;

let cfg = config.extensions.wstunnel;

in {

  ###### interface

  options = {

    extensions.wstunnel = {

      enable = mkOption {
        type = types.bool;
        default = false;
      };

      wsTunnelServer = mkOption { type = types.str; };

      localToRemote = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      dynamicToRemote = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      udp = mkOption {
        type = types.bool;
        default = false;
      };

      udpTimeoutSec = mkOption {
        type = types.nullOr types.int;
        default = null;
      };

      httpProxy = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      soMark = mkOption {
        type = types.nullOr types.int;
        default = null;
      };

      upgradePathPrefix = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      server = mkOption {
        type = types.bool;
        default = false;
      };

      restrictTo = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.wstunnel = {
      description = "wstunnel";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.wstunnel ];
      serviceConfig = {
        # User
        DynamicUser = true;
        # Capabilities
        AmbientCapabilities = [ "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_RAW" "CAP_NET_BIND_SERVICE" ];
        # Security
        NoNewPrivileges = true;
        # Sandboxing
        ProtectSystem = "strict";
        ProtectHome = mkDefault true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        # System Call Filtering
        SystemCallArchitectures = "native";
      };
      script = let
        option = key:
          let value = getAttr key cfg;
          in if value == null then "" else "--${key}=${toString value}";
      in ''
        exec wstunnel --verbose \
          ${if cfg.udp then "--udp" else ""} \
          ${if cfg.server then "--server" else ""} \
          ${option "localToRemote"} \
          ${option "dynamicToRemote"} \
          ${option "udpTimeoutSec"} \
          ${option "httpProxy"} \
          ${option "soMark"} \
          ${option "upgradePathPrefix"} \
          ${option "restrictTo"} \
          ${cfg.wsTunnelServer}
      '';
    };
  };
}
