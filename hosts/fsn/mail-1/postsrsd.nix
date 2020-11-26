{ ... }:

{
  services.postsrsd = {
    enable = true;
    domain = "lama-corp.space";
    excludeDomains = [
      "risson.space"
      "risson.me"
      "risson.tech"
      "risson.rocks"
      "lewdax.space"
      "marcerisson.space"
    ];
  };
}
