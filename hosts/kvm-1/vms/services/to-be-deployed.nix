{ config, pkgs, lib, system, vmName, localDiskSize ? 10, persistDiskSize ? 1
, xml }:

with lib;

let
  imageLocal = import ../images/local.nix { inherit config pkgs system; };
  imagePersist = import ../images/persist.nix { inherit config pkgs system; };

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
    if ! ${pkgs.libvirt}/bin/virsh vol-key '${vmName}-local.qcow2' --pool default &> /dev/null; then
      ${pkgs.qemu}/bin/qemu-img convert -f qcow2 -O qcow2 -o preallocation=metadata ${imageLocal}/image.qcow2 /srv/vm/${vmName}-local.qcow2
      ${pkgs.libvirt}/bin/virsh pool-refresh default
      ${pkgs.libvirt}/bin/virsh vol-resize '${vmName}-local.qcow2' ${
        toString localDiskSize
      }G --pool default
    fi

    if ! ${pkgs.libvirt}/bin/virsh vol-key '${vmName}-persist.qcow2' --pool default &> /dev/null; then
      ${pkgs.qemu}/bin/qemu-img convert -f qcow2 -O qcow2 -o preallocation=metadata ${imagePersist}/image.qcow2 /srv/vm/${vmName}-persist.qcow2
      ${pkgs.libvirt}/bin/virsh pool-refresh default
      ${pkgs.libvirt}/bin/virsh vol-resize '${vmName}-persist.qcow2' ${
        toString persistDiskSize
      }G --pool default
    fi

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
