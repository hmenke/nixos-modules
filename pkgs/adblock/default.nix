{ stdenv, lib, fetchFromGitHub, alternative ? "hosts" }:

stdenv.mkDerivation rec {
  pname = "adblock";
  version = "3.9.43";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-+w5ESk6T6hDTnjjsxEM8QaYrgfhd1lzEOyfwD3DylJg=";
  };

  installPhase = ''
    mkdir -p $out/etc $out/etc/unbound $out/etc/kresd
    sed '/^fe80::1%lo0/d' ${alternative} > $out/etc/hosts
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
