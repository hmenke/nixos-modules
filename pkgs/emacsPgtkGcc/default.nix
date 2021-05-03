{ lib
, fetchFromSavannah
, fetchpatch
, emacs
}:
let
  version = "20210427.0";
  rev = "66a36f1e5a323aed3d39db1044a1b71373123832";
in
(emacs.override {
  nativeComp = true;
  srcRepo = true;
}).overrideAttrs ({ configureFlags, postPatch, ... }: {
  name = "emacs-pgtkgcc-${version}";
  inherit version;
  src = fetchFromSavannah {
    repo = "emacs";
    inherit rev;
    sha256 = "0pblfz3vj6j2z8anrqw6cfshfpgv7d2wgy5a5gckwlxcp7hfnrq2";
  };

  configureFlags = (lib.subtractLists [ "--with-nativecomp" "--with-xft" ] configureFlags)
    ++ lib.singleton "--with-native-compilation"
    ++ lib.singleton "--with-pgtk";

  patches = [
    (fetchpatch {
      url = "https://github.com/nix-community/emacs-overlay/raw/fab25e7e94d1ea5ef94330a88afefe9318255763/patches/tramp-detect-wrapped-gvfsd.patch";
      sha256 = "sha256-nW2582royQJ1Prg1jy6wpv2uGctzomByHK2eZIo4f+c=";
    })
  ];

  postPatch = postPatch + ''
    substituteInPlace lisp/loadup.el \
    --replace '(emacs-repository-get-version)' '"${rev}"' \
    --replace '(emacs-repository-get-branch)' '"master"'
  '';
})
