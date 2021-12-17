{ stdenv, lib, fetchFromGitHub, alternative ? "hosts" }:

stdenv.mkDerivation rec {
  pname = "adblock";
  version = "3.9.27";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-9QN0GpTi+EK9RBbOyoTzw6Ele6uvUI5zSLe3Qada/uo=";
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
