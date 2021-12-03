final: prev: {
  bird-lg-go-frontend = prev.callPackage ./bird-lg-go/frontend.nix { };
  bird-lg-go-proxy = prev.callPackage ./bird-lg-go/proxy.nix { };

  tmuxp = prev.callPackage ./tmuxp { };
}
