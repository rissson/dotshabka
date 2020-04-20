{ ... }:

{
  services.logrotate = {
    enable = true;
    config = ''
      compress
      /var/log/smartd/* {
        rotate 5
        weekly
        olddir /var/log/smartd/old
      }

      /var/log/nginx/* {
        rotate 5
        weekly
        olddir /var/log/nginx/old
      }
    '';
  };
}
