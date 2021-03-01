{ pkgs, lib, ...}:

with pkgs;

let
  /*hue = python37.pkgs.buildPythonPackage rec {
    pname = "hue";
    version = "1.0.0";

    # There are no tests
    doTest = false;

    src = /home/diego/prog/hue;
    propagatedBuildInputs = with python37.pkgs; [ click requests ];
  };*/

  global-python-packages = python-packages: with python-packages; [
    ptpython
    pip
    black
    #hue
    GitPython
    setuptools
    pygame
    Nuitka
    click
  ];
  python-with-global-packages = python37.withPackages global-python-packages;
in
  {
    home.packages = [
      poetry
      python-with-global-packages
    ];
  }
