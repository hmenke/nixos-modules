{ stdenv
, lib
, fetchFromGitHub
, bashInteractive
, rofi
, xdotool
, xsel
}:

stdenv.mkDerivation rec {
  pname = "splatmoji";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "cspeterson";
    repo = "splatmoji";
    rev = "v${version}";
    sha256 = "0fdnz290a0dp7adrl64pqcppr419x9xibh6pspcjyxwxp7h66a3x";
  };

  buildInputs = [ bashInteractive rofi xdotool xsel ];

  installPhase = ''
    mkdir -p $out/bin $out/share/splatmoji
    cp -r * $out/share/splatmoji
    cat <<EOF > $out/share/splatmoji/splatmoji.config
    rofi_command=${rofi}/bin/rofi -dmenu -p "" -i -theme gruvbox-dark
    xsel_command=${xsel}/bin/xsel -b -i
    xdotool_command=${xdotool}/bin/xdotool sleep 0.2 type --delay 100
    EOF
    ln -s $out/share/splatmoji/splatmoji $out/bin/splatmoji
  '';
}
