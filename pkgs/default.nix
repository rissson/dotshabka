final: prev: {
  libvcs = final.callPackage ./libvcs { };

  netdata = prev.callPackage ./netdata {
    inherit (prev.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
  };

  tmuxp = prev.callPackage ./tmuxp { };

  vcspull = final.callPackage ./vcstool { };
}
