{ ... }:

{
  programs.tmux.tmuxp = {
    enable = true;
    settings = {
      blog = import ./blog.nix;
      cri = import ./cri.nix;
      cri-blog = import ./cri-blog.nix;
      cri-intranet = import ./cri-intranet.nix;
      cri-k8s = import ./cri-k8s.nix;
      cri-myfirewall = import ./cri-myfirewall.nix;
      lama-corp-hub = import ./lama-corp-hub.nix;
      soxincfg = import ./soxincfg.nix;
    };
  };
}
