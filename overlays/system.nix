final: prev: {
  adblock = final.callPackage ../pkgs/adblock { };
  drone-runner-docker = final.callPackage ../pkgs/drone-runner-docker { };
  libfprint-tod = final.callPackage ../pkgs/libfprint-tod { };
  libfprint-tod-goodix = final.callPackage ../pkgs/libfprint-tod-goodix { };
}
