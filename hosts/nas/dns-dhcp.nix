{ pkgs, ... }:

let

  dotshabka = import ../.. {};

  hostsFile = pkgs.writeTextFile {
    name = "hosts";
    executable = false;
    destination = "/share/hosts";
    text = with dotshabka.data.iPs.space.lama-corp.bar; ''
      ${srv.cuckoo.internal.v4.ip}      cuckoo      cuckoo.srv.bar.lama-corp.space

      ${lap.asus.internal.v4.ip}        asus        asus.lap.bar.lama-corp.space

      ${mmd.loewe.internal.v4.ip}       loewe       loewe.mmd.bar.lama-corp.space
      ${mmd.bose.internal.v4.ip}        bose        bose.mmd.bar.lama-corp.space
      ${mmd.chromecast.internal.v4.ip}  chromecast  chromecast.mmd.bar.lama-corp.space

      ${prt.hp.internal.v4.ip}          hp          hp.prt.bar.lama-corp.space

      ${wfi.floor0.internal.v4.ip}      floor0      floor0.wfi.bar.lama-corp.space
      ${wfi.floor-1.internal.v4.ip}     floor-1     floor-1.wfi.bar.lama-corp.space

      ${srv.nas.internal.v4.ip}         nas         nas.srv.bar.lama-corp.space
      ${srv.livebox.internal.v4.ip}     livebox     livebox.srv.bar.lama-corp.space
    '';
  };

  defaultLeaseTime = "12h";

in {
  services.dnsmasq = with dotshabka.data.iPs.space.lama-corp.bar; {
    enable = true;
    resolveLocalQueries = false;
    servers = dotshabka.data.iPs.externalNameservers;
    extraConfig = ''
      ### Global settings

      # Interface not to listen on
      except-interface=${srv.nas.wg.interface}
      # Bind only to the others
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
      dhcp-option=option:router,${srv.livebox.internal.v4.ip}
      dhcp-option=option:dns-server,${srv.nas.internal.v4.ip},${builtins.elemAt dotshabka.data.iPs.externalNameservers 1}
      # Tell MicroSoft devices to release the lease when they shutdown
      dhcp-option=vendor:MSFT,2,1i
      # Fix WPA autoconfiguration vulnerabilities
      dhcp-name-match=set:wpad-ignore,wpad
      dhcp-ignore-names=tag:wpad-ignore

      ### DNS hosts and domains

      local=/bar.lama-corp.space/
      domain=bar.lama-corp.space

      domain=dhcp.bar.lama-corp.space,${dhcp.start},${dhcp.end}
      # range and lease time
      dhcp-range=${dhcp.start},${dhcp.end},${defaultLeaseTime}

      domain=srv.bar.lama-corp.space,${srv.start},${srv.end}
      dhcp-host=${srv.cuckoo.internal.mac},cuckoo,${srv.cuckoo.internal.v4.ip},${defaultLeaseTime}

      domain=lap.bar.lama-corp.space,${lap.start},${lap.end}
      dhcp-host=${lap.asus.internal.mac},asus,${lap.asus.internal.v4.ip},${defaultLeaseTime}

      domain=mmd.bar.lama-corp.space,${mmd.start},${mmd.end}
      dhcp-host=${mmd.loewe.internal.mac},loewe,${mmd.loewe.internal.v4.ip},${defaultLeaseTime}
      dhcp-host=${mmd.bose.internal.mac},bose,${mmd.bose.internal.v4.ip},${defaultLeaseTime}
      dhcp-host=${mmd.chromecast.internal.mac},chromecast,${mmd.chromecast.internal.v4.ip},${defaultLeaseTime}

      domain=prt.bar.lama-corp.space,${prt.start},${prt.end}
      dhcp-host=${prt.hp.internal.mac},hp,${prt.hp.internal.v4.ip},${defaultLeaseTime}

      domain=wfi.bar.lama-corp.space,${wfi.start},${wfi.end}
      dhcp-host=${wfi.floor0.internal.mac},floor0,${wfi.floor0.internal.v4.ip},${defaultLeaseTime}
      dhcp-host=${wfi.floor-1.internal.mac},floor-1,${wfi.floor-1.internal.v4.ip},${defaultLeaseTime}

      domain=srv.bar.lama-corp.space,192.168.44.250,192.168.44.254
      dhcp-host=${srv.nas.internal.mac},nas,${srv.nas.internal.v4.ip},${defaultLeaseTime}
      dhcp-host=${srv.livebox.internal.mac},livebox,${srv.livebox.internal.v4.ip},${defaultLeaseTime}
    '';
  };
}
