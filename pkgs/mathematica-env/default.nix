{ buildFHSUserEnvBubblewrap
, buildEnv
, runCommandLocal
, writeShellScriptBin
}:
let
  executables = [
    "math"
    "mathematica"
    "Mathematica"
    "MathKernel"
    "mcc"
    "wolfram"
    "WolframKernel"
    "wolframscript"
  ];

  fhs =
    buildFHSUserEnvBubblewrap {
      name = "mathematica-fhs";
      targetPkgs = pkgs: with pkgs; [
        # only needed during installtion
        bashInteractive
        coreutils
      ] ++ [
        alsaLib
        fontconfig
        libGL
        zlib
      ] ++ (with xorg; [
        libX11
        libXext
      ]);
      unshareNet = true;
      runScript = "";
      profile = ''
        export PATH="/opt/Wolfram/Mathematica/12.1/Executables''${PATH:+:$PATH}"
        export USE_WOLFRAM_LD_LIBRARY_PATH=1
        export QT_QPA_PLATFORM=xcb
        export QT_XCB_GL_INTEGRATION=none
      '';
    };

  makeFhsWrapper = name:
    writeShellScriptBin name ''
      exec "${fhs}/bin/mathematica-fhs" "${name}" "$@"
    '';

in
buildEnv {
  name = "mathematica-env";
  paths = [ fhs ] ++ (map makeFhsWrapper executables);
}
