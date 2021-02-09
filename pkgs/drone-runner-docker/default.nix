{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-runner-docker";
  version = "1.6.3";

  vendorSha256 = "sha256-tQPM91jMH2/nJ2pq8ExS/dneeLNb/vcL9kmEjyNtl5Y=";

  doCheck = false;

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ca4gyiqwpgf55ibyl87wl3kim1yqmagkdaw12dknrk5nzcsxv8n";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ hmenke ];
    license = licenses.unfreeRedistributable;
    description =
      "Drone pipeline runner that executes builds inside Docker containers";
  };
}
