{ buildPythonApplication
, fetchFromGitHub
, pyxdg
, pytest
}:

buildPythonApplication rec {
  pname = "pass-git-helper";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "languitar";
    repo = "pass-git-helper";
    rev = "v${version}";
    sha256 = "18nvwlp0w4aqj268wly60rnjzqw2d8jl0hbs6bkwp3hpzzz5g6yd";
  };

  propagatedBuildInputs = [ pyxdg ];
  checkInputs = [ pytest ];
  preCheck = ''
    export HOME=$(mktemp -d)
  '';
}
