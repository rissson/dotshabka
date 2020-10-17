{ config, ... }:

let port = 8003;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.codimd = {
    enable = false; # enabled by secrets
    configuration = {
      allowAnonymous = true;
      allowAnonymousEdits = true;
      allowEmailRegister = true;
      allowOrigin = [
        "md.lama-corp.space"
        "md.risson.space"
        "md.marcerisson.space"
        "md.risson.me"
        "md.risson.tech"
      ];
      defaultPermission = "freely";
      domain = "md.lama-corp.space";
      email = true;
      hsts.enable = false;
      imageUploadType = "minio";
      minio = {
        endpoint = "static.lama-corp.space";
        port = 443;
        secure = true;
      };
      s3bucket = "bin.lama-corp.space";
      useCDN = false;
      host = "0.0.0.0";
      inherit port;
      protocolUseSSL = true;
    };
  };
}
