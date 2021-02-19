{ stdenv
, python3Packages
}:

with python3Packages;

buildPythonApplication rec {
  pname = "tmuxp";
  version = "1.7.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-FClrYtsmBCDUYA3NgFQI6pCLOnjU6gpqQD0JL9v20HU=";
  };

  postPatch = ''
    sed -i 's/==.*$//' requirements/base.txt requirements/test.txt
  '';

  checkInputs = [
    pytest
    pytest-rerunfailures
  ];

  doCheck = false;

  propagatedBuildInputs = [
    click kaptan libtmux colorama
  ];

  meta = with stdenv.lib; {
    description = "Manage tmux workspaces from JSON and YAML";
    homepage = "https://tmuxp.git-pull.com";
    license = licenses.bsd3;
    maintainers = with maintainers; [ risson ];
  };
}
