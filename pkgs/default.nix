final: prev: {
  bird-lg-go-frontend = prev.callPackage ./bird-lg-go/frontend.nix { };
  bird-lg-go-proxy = prev.callPackage ./bird-lg-go/proxy.nix { };

  libvcs = final.callPackage ./libvcs { };

  netdata = prev.callPackage ./netdata {
    inherit (prev.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
  };

  tmuxp = prev.callPackage ./tmuxp { };

  vcspull = final.callPackage ./vcstool { };
}
