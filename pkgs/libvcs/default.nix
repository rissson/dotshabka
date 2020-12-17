{ stdenv
, python3Packages
}:

with python3Packages;

buildPythonApplication rec {
  pname = "libvcs";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1mcgp0j20602ha3v7jbh8zi5mh2l8c3cnpvl3b035dm1g5c1m026";
  };

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Synchronize projects via yaml/json manifest.";
    homepage = "https://vcspull.git-pull.com";
    license = licenses.bsd3;
    maintainers = with maintainers; [ risson ];
  };
}
