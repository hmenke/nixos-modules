{ stdenv, lib, fetchFromGitHub, alternative ? "hosts" }:

stdenv.mkDerivation rec {
  pname = "adblock";
  version = "3.15.26";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-D8Ebr02/O4avw/+60o8oZYII9pGz1veb+Gox6XOdQdg=";
  };

  installPhase = let
    serial = builtins.foldl' (x: y: 100 * x + lib.toInt y) 0 (lib.versions.splitVersion version);
  in ''
    mkdir -p $out/etc $out/etc/unbound $out/etc/kresd
    sed '/^fe80::1%lo0/d' ${alternative} > $out/etc/hosts
    awk '/^0\.0\.0\.0/ { print "local-zone: \"" $2 "\" always_nxdomain" }' ${alternative} > $out/etc/unbound/adblock.conf
    echo '$TTL 30' >> $out/etc/kresd/adblock.rpz
    echo '@ SOA localhost. root.localhost. ${toString serial} 300 1800 604800 30' >> $out/etc/kresd/adblock.rpz
    awk '
       /^#/ { print ";" substr($0,2) }
       /^0\.0\.0\.0 *0\.0\.0\.0/ { next }
       /^0\.0\.0\.0/ { print $2 " CNAME ." }
    ' ${alternative} >> $out/etc/kresd/adblock.rpz
  '';

  meta = {
    description =
      "Consolidating and extending hosts files from several well-curated sources";
    homepage = "https://github.com/StevenBlack/hosts";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hmenke ];
  };
}
