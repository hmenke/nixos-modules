{ gnuplot
, fetchgit
, autoconf
, automake
}:

let
  rev = "77ea54d590f14042f57f1b7cf495e8c588f74a9a";
in
(gnuplot.override {
  withQt = true;
  withLua = true;
}).overrideAttrs ({ nativeBuildInputs ? [], postPatch ? "", ... }: {
  version = "5.5+git20210209.${builtins.substring 0 7 rev}";

  src = fetchgit {
    url = "https://git.code.sf.net/p/gnuplot/gnuplot-main";
    rev = "77ea54d590f14042f57f1b7cf495e8c588f74a9a";
    sha256 = "sha256-07t/oe3kPoAGvRKDoryJ0PfkfFHiEpDmJpGwPB+h/xI=";
  };

  nativeBuildInputs = nativeBuildInputs ++ [ autoconf automake ];

  postPatch = ''
    ./prepare
    ${postPatch}
  '';
})
