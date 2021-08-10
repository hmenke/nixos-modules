{ stdenv, lib, fetchFromGitHub, alternative ? "hosts" }:

stdenv.mkDerivation rec {
  pname = "adblock";
  version = "3.8.6";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-QCorPe2MFvFdf0FBI9PQmP8hp5WPZBsKif1LYlMQmWc=";
  };

  installPhase = ''
    mkdir -p $out/etc $out/etc/unbound $out/etc/kresd
    cp ${alternative} $out/etc/hosts
    awk '/^0\.0\.0\.0/ { print "local-zone: \"" $2 "\" always_nxdomain" }' ${alternative} > $out/etc/unbound/adblock.conf
    awk '/^0\.0\.0\.0/ { print $2 "\tCNAME\t." }' ${alternative} > $out/etc/kresd/adblock.rpz
  '';

  meta = {
    description =
      "Consolidating and extending hosts files from several well-curated sources";
    homepage = "https://github.com/StevenBlack/hosts";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hmenke ];
  };
}
