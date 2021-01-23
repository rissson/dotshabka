{ ... }:

{
  programs.tmux.tmuxp = {
    enable = true;
    settings = {
      blog = import ./blog.nix;
      cri-blog = import ./cri-blog.nix;
      cri-intranet = import ./cri-intranet.nix;
      cri-myfirewall = import ./cri-myfirewall.nix;
      lama-corp-hub = import ./lama-corp-hub.nix;
      lama-corp-k8s = import ./lama-corp-k8s.nix;
      soxincfg = import ./soxincfg.nix;
    };
  };
}
