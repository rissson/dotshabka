{ pkgs, lib, ... }:

with lib;

let
  dotshabka = import <dotshabka> {};

  buildVmService = vmName: xml: {
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    restartIfChanged = false;

    script = ''
      uuid="$(${getBin pkgs.libvirt}/bin/virsh domuuid '${vmName}' || true)"
      ${getBin pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
      ${getBin pkgs.libvirt}/bin/virsh start '${vmName}'
    '';

    preStop = ''
      ${getBin pkgs.libvirt}/bin/virsh shutdown '${vmName}'
      let "timeout = $(date +%s) + 120"
      while [ "$(${getBin pkgs.libvirt}/bin/virsh list --name | grep --count '^${vmName}$')" -gt 0 ]; do
        if [ "$(date +%s)" -ge "$timeout" ]; then
          # Meh, we warned it...
          ${getBin pkgs.libvirt}/bin/virsh destroy '${vmName}'
        else
          # The machine is still running, let's give it some time to shut down
          sleep 1
        fi
      done
    '';
  };

in with dotshabka.data.space.lama-corp.fsn.srv.duck.virt; {
  systemd.services.libvirtd-guest-lewdax-ynh = buildVmService "lewdax-ynh" (
    pkgs.substituteAll {
      src = ./ynh.xml;

      kvmId = 1;
      name = "lewdax-ynh";
      macAddress = lewdax.mac;
      diskDevPath = "/dev/vg0/vm-lewdax-ynh";
      ifBridge = "br0";
    }
  );

  systemd.services.libvirtd-guest-lamacorp-ynh = buildVmService "lamacorp-ynh" (
    pkgs.substituteAll {
      src = ./ynh.xml;

      kvmId = 2;
      name = "lamacorp-ynh";
      macAddress = hub.mac;
      diskDevPath = "/dev/vg0/vm-lamacorp-ynh";
      ifBridge = "br0";
    }
  );
}
