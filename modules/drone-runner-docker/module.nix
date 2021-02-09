{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    nixpkgs.overlays = [ (final: prev: {
      drone-runner-docker = final.callPackage ../../pkgs/drone-runner-docker/default.nix { };
    }) ];
  };
}
