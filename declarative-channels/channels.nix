{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.extensions.declarative-channels;

  channelUrl = url:
    if hasPrefix "channel:" url then
      "https://nixos.org/channels/${removePrefix "channel:" url}"
    else
      url;

  fetchChannel = channelConfig:
    let
      inherit (channelConfig) url;
      inherit (channelConfig) sha256;
    in builtins.trace ''Fetching channel "${url}"'' (builtins.fetchTarball ({
      url = (channelUrl url) + "/nixexprs.tar.xz";
    } // (lib.optionalAttrs (sha256 != null) { inherit sha256; })));

  nixexprs = assert lib.assertMsg (hasAttr "nixos" cfg.channels) ''
    The "nixos" channel is required!
  '';
    fetchChannel (cfg.channels.nixos);

in {
  options = {
    extensions.declarative-channels = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Enable declarative channel configuration
        '';
      };
      channels = mkOption {
        type = types.attrsOf (types.submodule ({ ... }: {
          options = {
            url = mkOption {
              description = ''
                The channel URL
              '';
              type = types.str;
            };
            sha256 = mkOption {
              description = ''
                Optional hash for channel pinning
              '';
              default = null;
              type = types.nullOr types.str;
            };
          };
        }));
        default = { };
        example = literalExample ''
          {
            nixos = {
              url = "https://nixos.org/channels/nixos-20.03/nixexprs.tar.xz";
            };
          };
        '';
        description = ''
          Declarative channel configuration
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    # 12h tarball-ttl so channels don't have to be downloaded on
    # almost every nixos-rebuild
    nix.extraOptions = ''
      tarball-ttl = ${toString (12 * 60 * 60)}
    '';

    # Point NIX_PATH to the declarative channels
    nix.nixPath = [
      "nixpkgs=/etc/channels/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/etc/channels"
    ];

    # Most important: Use the declarative nixos channel for the system
    # configuration
    nixpkgs.pkgs = import "${nixexprs}" {
      inherit (config.nixpkgs) config overlays localSystem crossSystem;
    };

    system.autoUpgrade.channel = channelUrl cfg.channels.nixos.url;

    # Unpack channels into /etc/channels
    environment.etc = (mapAttrs' (channelName: channelConfig:
      nameValuePair ("channels/${channelName}") ({
        source = fetchChannel channelConfig;
      })) cfg.channels) // {

        # Just a little goody for myself
        "nixpkgs" = { source = "${nixexprs}"; };
      };

    # Tell command-not-found about the new channel location
    programs.command-not-found.dbPath = "/etc/channels/nixos/programs.sqlite";
  };
}
