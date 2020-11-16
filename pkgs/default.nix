final: prev: {
  netdata = prev.callPackage ./netdata {
    inherit (prev.darwin.apple_sdk.frameworks) CoreFoundation IOKit;
  };
}
