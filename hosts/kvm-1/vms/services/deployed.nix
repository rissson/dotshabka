{ config, pkgs, lib, system, vmName, localDiskSize ? 10, persistDiskSize ? 1
, xml }:

with lib;

{
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
    while [ "$(${
      getBin pkgs.libvirt
    }/bin/virsh list --name | grep --count '^${vmName}$')" -gt 0 ]; do
      if [ "$(date +%s)" -ge "$timeout" ]; then
        # Meh, we warned it...
        ${getBin pkgs.libvirt}/bin/virsh destroy '${vmName}'
      else
        # The machine is still running, let's give it some time to shut down
        sleep 1
      fi
    done
  '';
}
