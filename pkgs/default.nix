final: prev: {
  libvcs = final.callPackage ./libvcs { };

  netdata = prev.callPackage ./netdata {
    inherit (prev.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
  };

  vcspull = final.callPackage ./vcstool { };
}
