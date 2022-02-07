{ stdenv
, lib
, fetchFromGitHub
, nodePackages
, glib
, substituteAll
, gjs
}:
let
  rev = "afb4f12df1b8ca24dda6aff7ea157bedb8fff208";
in
stdenv.mkDerivation rec {
  pname = "pop-os-shell";
  version = "1.3.0+git20220201.${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    inherit rev;
    sha256 = "sha256-M52xKrYilnbf0wbV8fYOq9gT6z+YRisD37U4G/tXs98=";
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
