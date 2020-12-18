final: prev: {
  warsow = prev.warsow.overrideAttrs (o: rec {
    src = prev.fetchurl {
      url = "http://warsow.net/warsow-2.1.2.tar.gz";
      sha256 = "07y2airw5qg3s1bf1c63a6snjj22riz0mqhk62jmfm9nrarhavrc";
    };
  });
}
