{ stdenv
, lib
, fetchFromGitHub
, nodePackages
, glib
, substituteAll
, gjs
}:
let
  rev = "47d48291dfaed86b43011871b07b91d01aa0d2f6";
in
stdenv.mkDerivation rec {
  pname = "pop-os-shell";
  version = "1.3.0+git20210621.${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    inherit rev;
    sha256 = "sha256-IjZ09ykWH+ylmOkOeooE1Ec50f332F4ZK9KJA5oycTA=";
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
