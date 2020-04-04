{ pkgs, ... }:

let
  hostsFile = pkgs.writeTextFile {
    name = "hosts";
    executable = false;
    destination = "/share/hosts";
    text = ''
      192.168.44.201  cuckoo      cuckoo.srv.bar.lama-corp.space

      192.168.44.211  asus        asus.lap.bar.lama-corp.space

      192.168.44.221  loewe       loewe.mmd.bar.lama-corp.space
      192.168.44.222  bose        bose.mmd.bar.lama-corp.space
      192.168.44.223  chromecast  chromecast.mmd.bar.lama-corp.space

      192.168.44.231  hp          hp.prt.bar.lama-corp.space

      192.168.44.241  floor0      floor0.wfi.bar.lama-corp.space
      192.168.44.242  kitchen     kitchen.wfi.bar.lama-corp.space
      192.168.44.243  floor-1     floor-1.wfi.bar.lama-corp.space

      192.168.44.253  nas         nas.srv.bar.lama-corp.space
      192.168.44.254  livebox     livebox.srv.bar.lama-corp.space
    '';
  };
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    servers = [
      "1.1.1.1" "1.0.0.1" "208.67.222.222"
      "2606:4700:4700::1111" "2606:4700:4700::1001" "2620:119:35::35"
    ];
    extraConfig = ''
      # Only listen on local network
      listen-address=192.168.44.253
      # Interface to listen on, managed by the kernel
      interface=bond0
      bind-interfaces

      ### DNS settings

      # Number of DNS queries cached
      cache-size=1000
      no-negcache
      domain-needed
      bogus-priv
      no-poll
      no-hosts
      no-resolv
      expand-hosts
      addn-hosts=${hostsFile}/share/hosts

      ### DHCP settings

      dhcp-authoritative
      dhcp-rapid-commit
      dhcp-option=option:router,192.168.44.254
      dhcp-option=option:dns-server,192.168.44.253,1.1.1.1
      # Tell MicroSoft devices to release the lease when they shutdown
      dhcp-option=vendor:MSFT,2,1i
      # Fix WPA autoconfiguration vulnerabilities
      dhcp-name-match=set:wpad-ignore,wpad
      dhcp-ignore-names=tag:wpad-ignore

      ### DNS hosts and domains

      local=/bar.lama-corp.space/
      domain=bar.lama-corp.space

      domain=dhcp.bar.lama-corp.space,192.168.44.100,192.168.44.199
      # range and lease time
      dhcp-range=192.168.44.100,192.168.44.199,12h

      domain=srv.bar.lama-corp.space,192.168.44.200,192.168.44.209
      dhcp-host=00:01:2e:48:df:6d,cuckoo,192.168.44.201,12h

      domain=lap.bar.lama-corp.space,192.168.44.210,192.168.44.219
      dhcp-host=94:10:3e:f6:43:35,asus,192.168.44.211,12h

      domain=mmd.bar.lama-corp.space,192.168.44.220,192.168.44.229
      dhcp-host=00:09:82:17:1c:c0,loewe,192.168.44.221,12h
      dhcp-host=08:df:1f:08:49:34,bose,192.168.44.222,12h
      dhcp-host=48:d6:d5:27:2b:b4,chromecast,192.126.44.223,12h

      domain=prt.bar.lama-corp.space,192.168.44.230,192.168.44.239
      dhcp-host=88:51:fb:1b:21:f4,hp,192.168.44.231,12h

      domain=wfi.bar.lama-corp.space,192.168.44.240,192.168.44.249
      dhcp-host=44:fe:3b:1b:ed:3e,floor0,192.168.44.241,12h
      dhcp-host=00:e0:4c:90:a8:52,kitchen,192.168.44.242,12h

      domain=srv.bar.lama-corp.space,192.168.44.250,192.168.44.254
      dhcp-host=8e:3d:9b:ab:c9:c5,nas,192.168.44.253,12h
      dhcp-host=78:81:02:13:49:4e,livebox,192.168.44.254,12h
    '';
  };
}
