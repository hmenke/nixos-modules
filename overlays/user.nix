final: prev: {
  mathematica-env = final.callPackage ../pkgs/mathematica-env { };
  softmaker-office-2018-976 = final.softmaker-office.override {
    officeVersion = {
      version = "976";
      edition = "2018";
      hash = "sha256-A45q/irWxKTLszyd7Rv56WeqkwHtWg4zY9YVxqA/KmQ=";
    };
  };
  texlive-env = final.callPackage ../pkgs/texlive-env { };
  unison-bin = final.callPackage ../pkgs/unison-bin { };
}
