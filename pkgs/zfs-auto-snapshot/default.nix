{ stdenvNoCC
, lib
, fetchFromGitHub
, fetchpatch
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

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  dontBuild = true;

  meta = {
    description = "ZFS Automatic Snapshot Service for Linux";
    homepage = "https://github.com/zfsonlinux/zfs-auto-snapshot";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ hmenke ];
  };
}
