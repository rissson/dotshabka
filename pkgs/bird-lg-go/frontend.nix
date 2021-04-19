{ lib, buildGoModule, fetchFromGitHub, go-bindata }:

buildGoModule rec {
  pname = "bird-lg-go-frontend";
  version = "unstable";
  commit = "794125a96fa075a09a0090dacd6a94295b0bccd3";

  src = (fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = commit;
    sha256 = "sha256-1wxSB+oUaJD9nRo3DXQ7qWHAxp54vRVhenHqJezpfuc=";
  }) + "/frontend";

  vendorSha256 = "sha256-jeQc6w4/0wWmvdEM370RUw2svvRqGIY1Ji4UDzOwP7M=";

  nativeBuildInputs = [ go-bindata ];

  doCheck = false;

  preBuild = ''
    go generate
  '';

  meta = with lib; {
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3;
    maintainers = with maintainers; [ risson ];
  };
}
