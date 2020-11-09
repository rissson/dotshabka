final: prev: {
  flannel = prev.flannel.overrideAttrs (o: rec {
    version = "0.13.0";
    rev = "v${version}";

    src = prev.fetchFromGitHub {
      inherit rev;
      owner = "coreos";
      repo = "flannel";
      sha256 = "0mmswnaybwpf18h832haapcs5b63wn5w2hax0smm3inldiggsbw8";
    };

    patches = [ ./1322-crash-when-failure.patch ];
  });
}
