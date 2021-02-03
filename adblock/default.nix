{ stdenv, lib, fetchFromGitHub, alternative ? "hosts" }:

stdenv.mkDerivation rec {
  pname = "adaway";
  version = "3.3.9";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-rx4vYuX9y7QyHp+gVgS0ixYwBg/gUz3Zp0ULRC7LnLY=";
  };

  installPhase = ''
    mkdir -p $out/etc/unbound
    cp ${alternative} $out/etc/hosts
    grep '^0\.0\.0\.0' ${alternative} | awk '{ print "local-zone: \"" $2 "\" always_nxdomain" }' > $out/etc/unbound/adblock.conf
  '';

  meta = {
    description =
      "Consolidating and extending hosts files from several well-curated sources";
    homepage = "https://github.com/StevenBlack/hosts";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hmenke ];
  };
}