final: prev: {
  emacsPgtkGcc = final.callPackage ../pkgs/emacsPgtkGcc { };
  gitAndTools = prev.gitAndTools // {
    pass-git-helper = final.python3Packages.callPackage ../pkgs/pass-git-helper { };
  };
  masterpdfeditor-free = final.callPackage ../pkgs/masterpdfeditor-free { };
  mathematica-env = final.callPackage ../pkgs/mathematica-env { };
  nix-direnv = prev.nix-direnv.override { nix = final.nixFlakes; };
  nixos-shell = prev.nixos-shell.override { nix = final.nixFlakes; };
  pop-os-shell = final.callPackage ../pkgs/pop-os-shell { };
  softmaker-office = prev.softmaker-office.override {
    officeVersion = {
      version = "976";
      edition = "2018";
      sha256 = "sha256-A45q/irWxKTLszyd7Rv56WeqkwHtWg4zY9YVxqA/KmQ=";
    };
  };
  splatmoji = final.callPackage ../pkgs/splatmoji { };
  texlive-env = final.callPackage ../pkgs/texlive-env { };
  zoom-us-xcb = final.symlinkJoin {
    name = "zoom-us-xcb";
    paths = [ final.zoom-us ];
    buildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zoom --set QT_QPA_PLATFORM "xcb"
      wrapProgram $out/bin/zoom-us --set QT_QPA_PLATFORM "xcb"
      rm -f "$out/share/applications/Zoom.desktop"
      substitute \
        "${final.zoom-us}/share/applications/Zoom.desktop" \
        "$out/share/applications/Zoom.desktop" \
        --replace "${final.zoom-us}/bin/zoom" "$out/bin/zoom"
    '';
  };
}
