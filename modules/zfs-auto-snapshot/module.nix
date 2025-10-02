{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.extensions.zfs-auto-snapshot;

  snapshotNames = [ "frequent" "hourly" "daily" "weekly" "monthly" ];

in {

  ###### interface

  options = {

    extensions.zfs-auto-snapshot = {

      enable = mkOption {
        type = types.bool;
        default = false;
      };

      flags = mkOption {
        type = types.str;
        default = "";
      };

      frequent = mkOption {
        type = types.int;
        default = 4;
      };

      hourly = mkOption {
        type = types.int;
        default = 24;
      };

      daily = mkOption {
        type = types.int;
        default = 7;
      };

      weekly = mkOption {
        type = types.int;
        default = 4;
      };

      monthly = mkOption {
        type = types.int;
        default = 12;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (final: prev: {
      zfs-auto-snapshot = final.callPackage ../../pkgs/zfs-auto-snapshot { };
    }) ];

    environment.systemPackages = [ pkgs.zfs-auto-snapshot ];

    systemd.services = let
      keep = name: toString (builtins.getAttr name cfg);
    in builtins.listToAttrs (map (snapName:
      {
        name = "zfs-auto-snapshot-${snapName}";
        value = {
          description = "zfs-auto-snapshot ${snapName}";
          after = [ "zfs-import.target" ];
          path = [ pkgs.zfs-auto-snapshot pkgs.zfs ];
          script = ''
            zfs-auto-snapshot ${cfg.flags} --default-exclude --label=${snapName} --keep=${keep snapName} --post-snapshot=${lib.escapeShellArg ''sh -c 'zfs bookmark "$1@$2" "$1#$2"' --''} '//'

            # Prune old snapshots with the same label from all datasets
            zfs list -H -t filesystem,volume -o name | while read -r volume; do
                zfs list -H -t snapshot -S creation -o name "$volume" |
                    grep -F "@zfs-auto-snap_${snapName}" |
                    tail -n "+$((${keep snapName} + 1))" |
                    xargs -r -l zfs destroy -d -v
            done
          '';
          restartIfChanged = false;
        };
      }) snapshotNames);

    systemd.timers = let
      timer = name: if name == "frequent" then "*:0/15" else name;
    in builtins.listToAttrs (map (snapName:
      {
        name = "zfs-auto-snapshot-${snapName}";
        value = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = timer snapName;
            Persistent = "yes";
          };
        };
      }) snapshotNames);
  };

}

