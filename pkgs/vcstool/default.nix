{ stdenv
, python3Packages
, libvcs
}:

with python3Packages;

buildPythonApplication rec {
  pname = "vcspull";
  version = "1.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1yys2n0scf2kflcxcyldks779yrz7lwryan1j9zgrnd8hc61z2r6";
  };

  doCheck = false;

  propagatedBuildInputs = [
    click kaptan libvcs colorama
  ];

  meta = with stdenv.lib; {
    description = "Synchronize projects via yaml/json manifest.";
    homepage = "https://vcspull.git-pull.com";
    license = licenses.bsd3;
    maintainers = with maintainers; [ risson ];
  };
}
