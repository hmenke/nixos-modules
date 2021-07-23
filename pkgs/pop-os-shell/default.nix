{ stdenv
, lib
, fetchFromGitHub
, nodePackages
, glib
, substituteAll
, gjs
}:
let
  rev = "9616931a2f8da33ff60d6332cbb1e4036c9ae2b3";
in
stdenv.mkDerivation rec {
  pname = "pop-os-shell";
  version = "1.3.0+git20210719.${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    inherit rev;
    sha256 = "sha256-lfXsBfye5PeVIGmeo0M4Tg/KZcANImZAHQKFQx5xrrU=";
  };

  nativeBuildInputs = [ glib nodePackages.typescript gjs ];

  buildInputs = [ gjs ];

  patches = [
    ./fix-gjs.patch
  ];

  makeFlags = [
    "INSTALLBASE=$(out)/share/gnome-shell/extensions"
    "PLUGIN_BASE=$(out)/share/pop-shell/launcher"
    "SCRIPTS_BASE=$(out)/share/pop-shell/scripts"
  ];

  postInstall = ''
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/floating_exceptions/main.js
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/color_dialog/main.js
  '';

   meta = {
    description = "Keyboard-driven layer for GNOME Shell";
    license = lib.licenses.gpl3Only;
    homepage = "https://github.com/pop-os/shell";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ hmenke remunds ];
  };
}
