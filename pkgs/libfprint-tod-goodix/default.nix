{ stdenv
, fetchgit 
, libfprint-tod
, autoPatchelfHook
, libusb
}:
stdenv.mkDerivation rec {
  pname = "libfprint-2-tod1-xps9300-bin";
  version = "0.0.6";

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  src = fetchgit {
    url = "git://git.launchpad.net/~oem-solutions-engineers/libfprint-2-tod1-goodix/+git/libfprint-2-tod1-goodix/";
    rev = "882735c6366fbe30149eea5cfd6d0ddff880f0e4"; # HEAD of branch droped-lp1880058
    sha256 = "sha256-Uv+Rr4V31DyaZFOj79Lpyfl3G6zVWShh20roI0AvMPU=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libfprint-tod
    libusb
  ];

  installPhase = ''
    install -dm 0755 "$out/lib/udev/rules.d/"
    install -dm 0755 "$out/lib/libfprint-2/tod-1/"

    sed -n -r '/Shenzhen/,/^\s*$/p' debian/copyright > LICENSE
    install -Dm 0644 LICENSE "$out/share/licenses/libfprint-2-tod1-xps9300-bin/LICENSE"

    install -Dm 0755 usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-tod-goodix-53xc-0.0.6.so "$out/lib/libfprint-2/tod-1/"
    install -Dm 0644 lib/udev/rules.d/60-libfprint-2-tod1-goodix.rules "$out/lib/udev/rules.d/"
  '';

  meta = with stdenv.lib; {
    homepage = "https://git.launchpad.net/~oem-solutions-engineers/libfprint-2-tod1-goodix/+git/libfprint-2-tod1-goodix";
    description = "Goodix driver module for libfprint-2 Touch OEM Driver";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jobojeha hmenke ];
  };
}
