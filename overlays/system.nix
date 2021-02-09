final: prev: {
  adblock = final.callPackage ../pkgs/adblock { };
  drone-runner-docker = final.callPackage ../pkgs/drone-runner-docker { };
}
