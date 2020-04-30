{ config, pkgs, lib, ... }:

with lib;

let
  baseImageBuilder = extraConfig: import ./image.nix {
    inherit config pkgs extraConfig;
    system = builtins.currentSystem;
  };

  buildVmService = { vmName, diskSize ? 20, xml, extraConfig }:
   let
     baseImage = baseImageBuilder extraConfig;
   in {
     after = [ "libvirtd.service" ];
     requires = [ "libvirtd.service" ];
     wantedBy = [ "multi-user.target" ];
     serviceConfig = {
       Type = "oneshot";
       RemainAfterExit = "yes";
     };
     restartIfChanged = false;

     script = ''
       if ! ${pkgs.libvirt}/bin/virsh vol-key '${vmName}.qcow2' --pool default &> /dev/null; then
         ${pkgs.qemu}/bin/qemu-img convert -f qcow2 -O qcow2 ${baseImage}/image.qcow2 /srv/vm/${vmName}.qcow2
         ${pkgs.libvirt}/bin/virsh pool-refresh default
         ${pkgs.libvirt}/bin/virsh vol-resize '${vmName}.qcow2' ${toString diskSize}G --pool default
       fi

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
in with import <dotshabka/data/space.lama-corp/fsn/srv> {}; {
  systemd.services.libvirtd-guest-mail-1 = with duck.mail-1; buildVmService rec {
    vmName = "mail-1";
    diskSize = 25;
    xml = (pkgs.substituteAll {
      src = ./vm-public.xml;

      inherit vmName;
      cpus = 2;
      ram = 4;
      macAddressPublic = external.mac;
      macAddressLocal = internal.mac;
      diskPath = "/srv/vm/${vmName}.qcow2";
      ifBridgePublic = "br-public";
      ifBridgeLocal = "br-local";
    });
    extraConfig = {
      networking = {
        hostName = vmName;
        domain = with config.networking; "${hostName}.${domain}";
        # required for ZFS
        inherit hostId;

        nameservers = [
          duck.internal.v4.ip
          duck.internal.v6.ip
        ];

        interfaces."${external.interface}" = {
          ipv4.addresses = [
            { address = external.v4.ip; prefixLength = external.v4.prefixLength; }
          ];
          ipv6.addresses = [
            { address = external.v6.ip; prefixLength = external.v6.prefixLength; }
          ];
        };
        interfaces."${internal.interface}" = {
          ipv4.addresses = [
            { address = internal.v4.ip; prefixLength = internal.v4.prefixLength; }
          ];
          ipv6.addresses = [
            { address = internal.v6.ip; prefixLength = internal.v6.prefixLength; }
          ];
        };
        defaultGateway = {
          address = external.v4.gw;
          interface = external.interface;
        };

        defaultGateway6 = {
          address = external.v6.gw;
          interface = external.interface;
        };
      };

      # libvirt messes around with interfaces names, so we need to pin it
      services.udev.extraRules = ''
        SUBSYSTEM=="net", ATTR{address}=="${external.mac}", NAME="${external.interface}"
        SUBSYSTEM=="net", ATTR{address}=="${internal.mac}", NAME="${internal.interface}"
      '';
    };
  };
}
