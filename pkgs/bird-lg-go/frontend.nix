{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "bird-lg-go-frontend";
  version = "unstable";
  commit = "3550362a4de9782be246757e990a84cc44b7f180";

  src = (fetchFromGitHub {
    owner = "xddxdd";
    repo = "bird-lg-go";
    rev = commit;
    sha256 = "sha256-SgcVaRYR5nHZGqhY65UPQ//8kycrcEEQWMBpv7OXcbE=";
  }) + "/frontend";

  vendorSha256 = "sha256-WKuVGiSV5LZrJ8/672TRN6tZNQxdCktHV6nx0ZxCP4A=";

  doCheck = false; # requires network

  meta = with lib; {
    description = "BIRD looking glass in Go, for better maintainability, easier deployment & smaller memory footprint";
    homepage = "https://github.com/xddxdd/bird-lg-go";
    license = licenses.gpl3;
    maintainers = with maintainers; [ risson ];
  };
}
