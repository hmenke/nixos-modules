{ stdenv
, lib
, fetchurl
, autoPatchelfHook  
, gtk2
, pango
}:

stdenv.mkDerivation rec {
  pname = "unison-bin";
  version = "2.52.0";
  ocamlVersion = "4.10.2";
  name = "${pname}-${version}+ocaml-${ocamlVersion}";

  src = fetchurl {
    url = "https://github.com/bcpierce00/unison/releases/download/v${version}/unison-v${version}+ocaml-${ocamlVersion}+x86_64.linux.tar.gz";
    sha256 = "sha256-9AEgBFGtXar0k+SnKq4me5OJSfJmaU885RPEo6wyqHE=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gtk2 pango ];

  dontConfigure = true;
  dontBuild = true;

  outputs = [ "out" "doc" ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $doc/share/${pname}
    cp -r bin/* $out/bin/
    cp unison-manual.* $doc/share/${pname}/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.cis.upenn.edu/~bcpierce/unison/";
    description = "Bidirectional file synchronizer";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ hmenke ];
    platforms = intersectLists platforms.linux platforms.x86_64;
  };
}
