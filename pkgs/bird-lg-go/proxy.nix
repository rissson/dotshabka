{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "bird-lg-go-proxy";
  version = "unstable";
  commit = "794125a96fa075a09a0090dacd6a94295b0bccd3";

  src = (fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = commit;
    sha256 = "sha256-1wxSB+oUaJD9nRo3DXQ7qWHAxp54vRVhenHqJezpfuc=";
  }) + "/proxy";

  vendorSha256 = "sha256-7LZeCY4xSxREsQ+Dc2XSpu2ZI8CLE0mz0yoThP7/OO4=";

  meta = with lib; {
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3;
    maintainers = with maintainers; [ risson ];
  };
}
