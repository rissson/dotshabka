{ lib, stdenv, callPackage, fetchFromGitHub, makeWrapper, autoreconfHook, pkgconfig
, CoreFoundation, IOKit, libossp_uuid
, curl, libcap,  libuuid, lm_sensors, zlib, fetchpatch
, nixosTests
, withCups ? false, cups
, withDBengine ? true, libuv, lz4, judy
, withIpmi ? (!stdenv.isDarwin), freeipmi
, withNetfilter ? (!stdenv.isDarwin), libmnl, libnetfilter_acct
, withSsl ? true, openssl
, withCloud ? true, libwebsockets_3_2, json_c
, withDebug ? false
}:

with lib;

let
  go-d-plugin = callPackage ./go.d.plugin.nix {};
  mosquitto = callPackage ./mosquitto.nix {};
in stdenv.mkDerivation rec {
  version = "1.28.0";
  pname = "netdata";

  src = fetchFromGitHub {
    owner = "netdata";
    repo = "netdata";
    rev = "v${version}";
    sha256 = "sha256-xCVvnauIEgCzQeYsXSHiMGknJEjMxA4A/CGXwt2Sxog=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig makeWrapper ];
  buildInputs = [ curl.dev zlib.dev ]
    ++ optionals withCloud [ json_c libwebsockets_3_2 ]
    ++ optionals stdenv.isDarwin [ CoreFoundation IOKit libossp_uuid ]
    ++ optionals (!stdenv.isDarwin) [ libcap.dev libuuid.dev ]
    ++ optionals withCups [ cups ]
    ++ optionals withDBengine [ libuv lz4.dev judy ]
    ++ optionals withIpmi [ freeipmi ]
    ++ optionals withNetfilter [ libmnl libnetfilter_acct ]
    ++ optionals withSsl [ openssl.dev ];

  patches = [
    ./no-files-in-etc-and-var.patch
  ];

  NIX_CFLAGS_COMPILE = optionalString withDebug "-O1 -ggdb -DNETDATA_INTERNAL_CHECKS=1";

  postInstall = ''
    ln -s ${go-d-plugin}/lib/netdata/conf.d/* $out/lib/netdata/conf.d
    ln -s ${go-d-plugin}/bin/godplugin $out/libexec/netdata/plugins.d/go.d.plugin
  '' + optionalString (!stdenv.isDarwin) ''
    # rename this plugin so netdata will look for setuid wrapper
    mv $out/libexec/netdata/plugins.d/apps.plugin \
       $out/libexec/netdata/plugins.d/apps.plugin.org
    mv $out/libexec/netdata/plugins.d/perf.plugin \
       $out/libexec/netdata/plugins.d/perf.plugin.org
    mv $out/libexec/netdata/plugins.d/slabinfo.plugin \
       $out/libexec/netdata/plugins.d/slabinfo.plugin.org
    ${optionalString withIpmi ''
      mv $out/libexec/netdata/plugins.d/freeipmi.plugin \
         $out/libexec/netdata/plugins.d/freeipmi.plugin.org
    ''}
  '';

  preConfigure = optionalString withCloud ''
    mkdir -p externaldeps
    cp -r ${mosquitto}/lib externaldeps/mosquitto
  '' + optionalString (!stdenv.isDarwin) ''
    substituteInPlace collectors/python.d.plugin/python_modules/third_party/lm_sensors.py \
      --replace 'ctypes.util.find_library("sensors")' '"${lm_sensors.out}/lib/libsensors${stdenv.hostPlatform.extensions.sharedLibrary}"'
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ] ++ optionals withCloud [
    "--enable-cloud"
  ];

  postFixup = ''
    wrapProgram $out/bin/netdata-claim.sh --prefix PATH : ${openssl}/bin
  '';

  passthru.tests.netdata = nixosTests.netdata;

  meta = {
    description = "Real-time performance monitoring tool";
    homepage = "https://www.netdata.cloud/";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = [ maintainers.lethalman ];
  };
}
