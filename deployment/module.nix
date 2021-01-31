{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    deployment.targetHost = mkOption {
      type = types.str;
    };

    deployment.targetPort = mkOption {
      type = types.int;
      default = 22;
    };

    deployment.keys = mkOption {
      type = types.attrsOf (types.submodule ({ ... }: {
        options = {
          path = mkOption {
            type = types.str;
          };
      
          source = mkOption {
            type = types.str;
          };
        };
      }));
    };

    deployment.copyKeys = mkOption {
      type = types.str;
      internal = true;
    };
  };

  config = {
    system.activationScripts = {
      check-keys = let
        inherit (config.deployment) keys;
        paths = mapAttrsToList (_: { path, ... }: "test -f \"${path}\"") keys;
      in
      concatStringsSep "\n" paths;
    };

    deployment.copyKeys = let
      inherit (config.deployment) targetHost targetPort keys;

      controlOpts = concatStringsSep " " [
        "-o ControlMaster=auto"
	"-o ControlPath=\"$tmpDir/ssh-master\""
	"-o ControlPersist=60"
      ];

      makeScpCmd = { path, source, ... }: ''
        echo "${source} -> ${targetHost}:${path}"
        scp ${controlOpts} -P ${toString targetPort} "${source}" root@${targetHost}:"${path}"
      '';

      paths = mapAttrsToList (_: key: makeScpCmd key) keys;
    in ''
      tmpDir=$(mktemp -d -p /dev/shm -t copy-keys.XXXXXX)
      ssh -x -M -N -f ${controlOpts} -p ${toString targetPort} root@${targetHost}
      cleanup() {
          ssh -x ${controlOpts} -O exit dummyhost 2>/dev/null || true
          rm -rf "$tmpDir"
      }
      trap cleanup EXIT
      ${concatStringsSep "\n" paths}
    '';
  };
}