{
  autorandr = ./programs/autorandr.nix;
  git = ./programs/git.nix;
  neovim = ./programs/neovim;
  starship = ./programs/starship.nix;
  tmux = ./programs/tmux.nix;
  tmuxp = ./programs/tmuxp.nix;

  unbound = ./services/networking/unbound.nix;

  libvirt = ./virtualisation/libvirtd.nix;
}
