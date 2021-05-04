{ lib
, fetchFromSavannah
, fetchpatch
, emacs
}:
let
  urlJSON = "https://github.com/nix-community/emacs-overlay/raw/master/repos/emacs/emacs-feature_pgtk.json";
  urlPatch = "https://github.com/nix-community/emacs-overlay/raw/master/patches/tramp-detect-wrapped-gvfsd.patch";
  repoMeta = builtins.fromJSON (builtins.readFile (builtins.fetchurl urlJSON));
in
(emacs.override {
  nativeComp = true;
  srcRepo = true;
}).overrideAttrs ({ configureFlags, postPatch, ... }: {
  name = "emacs-pgtkgcc-${repoMeta.version}";
  inherit (repoMeta) version;
  src = fetchFromSavannah {
    inherit (repoMeta) repo rev sha256;
  };

  configureFlags = (lib.subtractLists [ "--with-nativecomp" "--with-xft" ] configureFlags)
    ++ lib.singleton "--with-native-compilation"
    ++ lib.singleton "--with-pgtk";

  patches = [ (builtins.fetchurl urlPatch) ];

  postPatch = postPatch + ''
    substituteInPlace lisp/loadup.el \
    --replace '(emacs-repository-get-version)' '"${repoMeta.rev}"' \
    --replace '(emacs-repository-get-branch)' '"master"'
  '';
})
