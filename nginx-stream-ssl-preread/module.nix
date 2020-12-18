{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.extensions.nginx.streamSslPreread;

in {

  ###### interface

  options = {
    extensions.nginx.streamSslPreread = {
      enable = mkEnableOption {};
      port = mkOption {
        type = types.int;
        default = 443;
      };
      sslPort = mkOption {
        type = types.int;
        default = 8443;
      };
      order = mkOption {
        type = types.listOf types.str;
        default = attrNames cfg.streams;
      };
      streams = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            server = mkOption { type = types.str; };
            port = mkOption { type = types.int; };
            ssl_preread_protocol = mkOption {
              type = types.listOf types.str;
              default = [];
            };
            ssl_preread_alpn_protocols = mkOption {
              type = types.listOf types.str;
              default = [];
            };
          };
        });
      };
    };

    services.nginx.virtualHosts = mkOption {
      type = types.attrsOf (types.submodule {
        config = mkIf cfg.enable {
          forceSSL = true;
          listen = [
            { addr = "0.0.0.0"; port = cfg.sslPort; ssl = true; }
            { addr = "[::]"; port = cfg.sslPort; ssl = true; }
            { addr = "0.0.0.0"; port = 80; ssl = false; }
            { addr = "[::]"; port = 80; ssl = false; }
          ];
        };
      });
    };
  };

  ###### implementation

  config = let

    mapAttrsToListInOrder = f: attrs: order:
      map (name: f name attrs.${name}) order;

    mapStreamsToListInOrder = f: attrs:
      mapAttrsToListInOrder f attrs cfg.order;

    quoteOrDefault = s: if s == "default" then s else "\"${s}\"";

  in mkIf cfg.enable {
    assertions = [ {
      assertion = naturalSort cfg.order == naturalSort (attrNames cfg.streams);
      message = "The requested order is not exhaustive";
    } ];

    services.nginx.appendConfig = let
      upstreams = concatStringsSep "\n" (mapStreamsToListInOrder (name: value: ''
        upstream ${name} {
          server ${value.server}:${toString value.port};
        }
      '') cfg.streams);

      mapProtocols = let
        streams = filterAttrs (n: v: v.ssl_preread_protocol != null) cfg.streams;
        mappings = concatStringsSep "\n" (mapStreamsToListInOrder (name: value:
	  concatMapStringsSep "\n" (protocol: ''
            ${quoteOrDefault protocol} ${name};
          '') value.ssl_preread_protocol) streams);
      in ''
        map $ssl_preread_protocol $upstream {
          ${mappings}
        }
      '';

      mapAlpnProtocols = let
        streams = filterAttrs (n: v: v.ssl_preread_alpn_protocols != null) cfg.streams;
        mappings = concatStringsSep "\n" (mapStreamsToListInOrder (name: value:
	  concatMapStringsSep "\n" (protocol: ''
            ${quoteOrDefault protocol} ${name};
          '') value.ssl_preread_alpn_protocols) streams);
      in ''
        map $ssl_preread_alpn_protocols $upstream {
          ${mappings}
        }
      '';
    in ''
      stream {
        ${upstreams}

        ${mapAlpnProtocols}

        ${mapProtocols}

        server {
          listen ${toString cfg.port};
          proxy_pass $upstream;
          ssl_preread on;
        }
      }
    '';
  };
}
