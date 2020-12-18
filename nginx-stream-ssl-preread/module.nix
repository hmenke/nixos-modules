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
      mapHashBucketSize = mkOption {
        type = types.nullOr (types.enum [ 32 64 128 ]);
        default = null;
      };
      mapHashMaxSize = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
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
            { addr = "0.0.0.0"; port = cfg.sslPort; ssl = true; extraParameters = [ "proxy_protocol"]; }
            { addr = "[::]"; port = cfg.sslPort; ssl = true; extraParameters = [ "proxy_protocol"]; }
            { addr = "0.0.0.0"; port = 80; ssl = false; }
            { addr = "[::]"; port = 80; ssl = false; }
          ];
        };
      });
    };
  };

  ###### implementation

  config = let

    quoteOrDefault = s: if s == "default" then s else "\"${s}\"";

  in mkIf cfg.enable {

    services.nginx.appendConfig = let
      upstreams = concatStringsSep "\n" (mapAttrsToList (name: value: ''
        upstream ${name} {
          server ${value.server}:${toString value.port};
        }
      '') cfg.streams);

      mapProtocols = let
        streams = filterAttrs (n: v: v.ssl_preread_protocol != []) cfg.streams;
        mappings = mapAttrsToList (name: value:
	  concatMapStringsSep "\n" (protocol: ''
            ${quoteOrDefault protocol} ${name};
          '') value.ssl_preread_protocol) streams;
      in optionalString (mappings != []) ''
        map $ssl_preread_protocol $upstream {
          ${concatStringsSep "\n" mappings}
        }
      '';

      mapAlpnProtocols = let
        streams = filterAttrs (n: v: v.ssl_preread_alpn_protocols != []) cfg.streams;
        mappings = mapAttrsToList (name: value:
	  concatMapStringsSep "\n" (protocol: ''
            ${quoteOrDefault protocol} ${name};
          '') value.ssl_preread_alpn_protocols) streams;
      in optionalString (mappings != []) ''
        map $ssl_preread_alpn_protocols $upstream {
          ${concatStringsSep "\n" mappings}
        }
      '';
    in ''
      stream {
        ${upstreams}

        ${optionalString (cfg.mapHashBucketSize != null) ''
          map_hash_bucket_size ${toString cfg.mapHashBucketSize};
        ''}

        ${optionalString (cfg.mapHashMaxSize != null) ''
          map_hash_max_size ${toString cfg.mapHashMaxSize};
        ''}

        ${mapAlpnProtocols}

        ${mapProtocols}

        server {
          listen ${toString cfg.port};
          proxy_pass $upstream;
	  proxy_protocol on;
          ssl_preread on;
        }
      }
    '';

  };
}
