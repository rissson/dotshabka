{ stdenv, fetchFromGitHub, c-ares, cmake, libwebsockets_3_2, openssl }:

stdenv.mkDerivation rec {
  pname = "mosquitto";
  version = "1.6.8_Netdata-5";

  src = fetchFromGitHub {
    owner = "netdata";
    repo = "mosquitto";
    rev = "v.${version}";
    sha256 = "sha256-VN1a6AfRp/sh6rdepDUClc3/hbFKH2WVKNgGxYGz3Ss=";
  };

  buildInputs = [ c-ares libwebsockets_3_2 openssl ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DWITH_THREADING=YES"
    "-DWITH_WEBSOCKETS=YES"
    "-DWITH_STATIC_LIBRARIES=YES"
    "-DWITH_DOCS=NO"
  ];

  buildPhase = ''
    cd lib
    make install
  '';

  postInstall = ''
    cp $out/lib/libmosquitto_static.a $out/lib/libmosquitto.a
    cp $out/include/mosquitto.h $out/lib/mosquitto.h
  '';
}
