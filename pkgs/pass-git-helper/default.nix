{ buildPythonApplication
, fetchFromGitHub
, pyxdg
, pytest
, pytest-mock
}:

buildPythonApplication rec {
  pname = "pass-git-helper";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "languitar";
    repo = "pass-git-helper";
    rev = "v${version}";
    sha256 = "sha256-GdsFPpBdoEaOCmdKxw5xTuFOcGFH94w5q/lV891lCUs=";
  };

  propagatedBuildInputs = [ pyxdg ];
  checkInputs = [ pytest pytest-mock ];
  preCheck = ''
    export HOME=$(mktemp -d)
  '';
}
