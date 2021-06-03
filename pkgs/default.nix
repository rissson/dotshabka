final: prev: {
  bird-lg-go-frontend = prev.callPackage ./bird-lg-go/frontend.nix { };
  bird-lg-go-proxy = prev.callPackage ./bird-lg-go/proxy.nix { };

  libvcs = final.callPackage ./libvcs { };

  tmuxp = prev.callPackage ./tmuxp { };

  vcspull = final.callPackage ./vcstool { };
}
