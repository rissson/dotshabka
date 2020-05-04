{ config, ... }:

let port = 8003;
in {
  networking.firewall.allowedTCPPorts = [ port ];
  services.codimd = {
    enable = false; # enabled by secrets
    workDir = "/srv/codimd";
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
      host = with config.networking; "${hostName}.${domain}";
      inherit port;
      protocolUseSSL = true;
    };
  };
}
