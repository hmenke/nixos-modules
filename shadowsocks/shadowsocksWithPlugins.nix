{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.shadowsocksWithPlugins;

  opts = {
    server = cfg.localAddress;
    server_port = cfg.port;
    method = cfg.encryptionMethod;
    mode = cfg.mode;
    user = "nobody";
    fast_open = cfg.fastOpen;
  } // optionalAttrs (cfg.nameserver != null) { nameserver = cfg.nameserver; }
    // optionalAttrs (cfg.plugin != null) {
      plugin = cfg.plugin;
      plugin_opts = cfg.pluginOpts;
    } // optionalAttrs (cfg.password != null) { password = cfg.password; };

  configFile = pkgs.writeText "shadowsocks.json" (builtins.toJSON opts);

in {

  ###### interface

  options = {

    services.shadowsocksWithPlugins = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run shadowsocks-libev shadowsocks server.
        '';
      };

      localAddress = mkOption {
        type = types.coercedTo types.str singleton (types.listOf types.str);
        default = [ "[::0]" "0.0.0.0" ];
        description = ''
          Local addresses to which the server binds.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 8388;
        description = ''
          Port which the server uses.
        '';
      };

      password = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Password for connecting clients.
        '';
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Password file with a password for connecting clients.
        '';
      };

      mode = mkOption {
        type = types.enum [ "tcp_only" "tcp_and_udp" "udp_only" ];
        default = "tcp_and_udp";
        description = ''
          Relay protocols.
        '';
      };

      fastOpen = mkOption {
        type = types.bool;
        default = true;
        description = ''
          use TCP fast-open
        '';
      };

      encryptionMethod = mkOption {
        type = types.str;
        default = "chacha20-ietf-poly1305";
        description = ''
          Encryption method. See <link xlink:href="https://github.com/shadowsocks/shadowsocks-org/wiki/AEAD-Ciphers"/>.
        '';
      };

      nameserver = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name servers for internal DNS resolver
        '';
      };

      plugin = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          SIP003 plugin for shadowsocks
        '';
      };

      pluginOpts = mkOption {
        type = types.str;
        default = "";
        description = ''
          Options for plugin
        '';
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = cfg.password == null || cfg.passwordFile == null;
      message =
        "Cannot use both password and passwordFile for shadowsocks-libev";
    };

    systemd.services.shadowsocks-libev = {
      description = "shadowsocks-libev Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.shadowsocks-libev cfg.plugin ]
        ++ optional (cfg.passwordFile != null) pkgs.jq;
      serviceConfig.PrivateTmp = true;
      script = ''
        ${optionalString (cfg.passwordFile != null) ''
          cat ${configFile} | jq --arg password "$(cat "${cfg.passwordFile}")" '. + { password: $password }' > /tmp/shadowsocks.json
        ''}
        exec ss-server -c ${
          if cfg.passwordFile != null then
            "/tmp/shadowsocks.json"
          else
            configFile
        }
      '';
    };
  };
}
