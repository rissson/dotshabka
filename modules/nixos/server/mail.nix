{ config, ... }:

{
  services.postfix = {
    enable = true;
    hostname = "lama-corp.space";
  };
}
