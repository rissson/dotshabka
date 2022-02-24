{ lib, stdenvNoCC, fetchFromGitHub, kubectl }:

stdenvNoCC.mkDerivation rec {
  pname = "konfig";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "corneliusweig";
    repo = "konfig";
    rev = "v${version}";
    sha256 = "sha256-qcYDiQJqXEWrGEwVdiB7922M8xT9mcbMdMBst5STOJk=";
  };

  propagatedBuildInputs = [ kubectl ];

  installPhase = ''
    install -Dm755 ./konfig $out/bin/konfig
  '';

  postInstall = ''
    substituteInPlace $out/bin/konfig \
      --replace kubectl ${kubectl}/bin/kubectl
  '';

  meta = with lib; {
    description = "konfig helps to merge, split or import kubeconfig files";
    homepage = "https://github.com/corneliusweig/konfig";
    license = licenses.asl20;
    maintainers = with maintainers; [ risson ];
  };
}
