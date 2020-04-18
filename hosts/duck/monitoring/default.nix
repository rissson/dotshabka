{ config, lib, ... }:

with lib;

{
  services.netdata = {
    enable = true;
  };

  environment.etc = mkIf config.services.netdata.enable {
    "netdata/python.d.conf".text = ''
      example: no
      logind: yes
      web_log: yes
    '';

    "netdata/python.d/nginx.conf".text = ''
      local:
        url: 'http://localhost/nginx_status'
    '';

    "netdata/python.d/web_log.conf".text = ''
      nginx_global:
        name: 'nginx global'
        path: /var/log/nginx/access.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_acdc_risson_space:
        name: 'acdc_risson_space'
        path: /var/log/nginx/access-acdc.risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'
        categories:
          conflooses: '^/conflooses/'
          photos: '^/photos/'

      nginx_beauflard_risson_space:
        name: 'beauflard_risson_space'
        path: /var/log/nginx/access-beauflard.risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_bin_lama-corp_space:
        name: 'bin_lama-corp_space'
        path: /var/log/nginx/access-bin.lama-corp.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_cats_acdc_risson_space:
        name: 'cats_acdc_risson_space'
        path: /var/log/nginx/access-cats.acdc.risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_md_lama-corp_space:
        name: 'md_lama-corp_space'
        path: /var/log/nginx/access-md.lama-corp.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_jdmi_risson_space:
        name: 'jdmi_risson_space'
        path: /var/log/nginx/access-jdmi.risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_lama-corp_space:
        name: 'lama-corp_space'
        path: /var/log/nginx/access-lama-corp.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_chat_lama-corp_space:
        name: 'chat_lama-corp_space'
        path: /var/log/nginx/access-chat.lama-corp.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_risson_space:
        name: 'risson_space'
        path: /var/log/nginx/access-risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'
        categories:
          blog: '^/yabdb/'

      nginx_scoreboard-seedbox-cri_risson_space:
        name: 'scoreboard-seedbox-cri_risson_space'
        path: /var/log/nginx/access-scoreboard-seedbox-cri.risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_thefractal_space:
        name: 'thefractal_space'
        path: /var/log/nginx/access-thefractal.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'

      nginx_upload_risson_space:
        name: 'upload_risson_space'
        path: /var/log/nginx/access-upload.risson.space.log
        custom_log_format:
          pattern: '(?P<vhost>[a-zA-Z\d.-_\[\]]+) (?P<port>\d+) (?P<address>[\da-f.:]+) .* "(?P<method>[A-Z]+)[^"]*" (?P<code>[1-9]\d{2}) (?P<bytes_sent>\d+) (?P<resp_length>\d+) (?P<resp_time>\d+)'
    '';
  };
}
