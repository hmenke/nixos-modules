{ stdenvNoCC
, lib
, fetchFromGitHub
, fetchpatch
, coreutils
, gawk
, getopt
, gnugrep
, zfs
}:

stdenvNoCC.mkDerivation rec {
  pname = "zfs-auto-snapshot";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "zfsonlinux";
    repo = "zfs-auto-snapshot";
    rev = "upstream/${version}";
    sha256 = "sha256-2O1NjFelumZCfk3wk7OHh5bM7hlh8eTaL3ZRXODhnVQ=";
  };

  buildInputs = [ coreutils gawk getopt gnugrep zfs ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  dontBuild = true;

  postFixup = ''
    sed -i '2 i export PATH="${lib.makeBinPath buildInputs}\''${PATH:+:\$PATH}"' $out/bin/zfs-auto-snapshot
  '';

  meta = {
    description = "ZFS Automatic Snapshot Service for Linux";
    homepage = "https://github.com/zfsonlinux/zfs-auto-snapshot";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ hmenke ];
  };
}
