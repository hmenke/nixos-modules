{ stdenv
, mathematica
, requireFile
, runtimeShell
}:
let
  version = "12.1.1";
  mathematica-firejail-unwrapped =
    let
      name = "Mathematica_${version}_LINUX.sh";
      sha256 = "02mk8gmv8idnakva1nc7r7mx8ld02lk7jgsj1zbn962aps3bhixd";
    in
    mathematica.overrideAttrs (_: {
      name = "mathematica-firejail-unwrapped-${version}";
      inherit version;
      src = requireFile {
        inherit name sha256;
        message = ''
          This nix expression requires that ${name} is
          already part of the store. Find the file on your Mathematica CD
          and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
        '';
      };
    });
in
stdenv.mkDerivation {
  name = "mathematica-firejail-${version}";
  buildCommand =
    ''
      mkdir -p $out/bin
    '' + builtins.foldl'
      (l: r:
        l + ''
          cat > "$out/bin/${r}" <<EOF
          #! ${runtimeShell} -e
          export USE_WOLFRAM_LD_LIBRARY_PATH=1
          export QT_XCB_GL_INTEGRATION=none
          exec /run/wrappers/bin/firejail --noprofile --net=none "${mathematica-firejail-unwrapped}/bin/${r}" "\$@"
          EOF
          chmod 0755 "$out/bin/${r}"
        '') "" [
      "math"
      "mathematica"
      "Mathematica"
      "MathKernel"
      "mcc"
      "wolfram"
      "WolframKernel"
    ];
}
