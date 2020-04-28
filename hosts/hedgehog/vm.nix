{ config, pkgs, lib, ... }:

{
  environment.etc."virt/base-images/baseline.qcow2".source = "${import ./image.nix {
    inherit config pkgs; system = builtins.currentSystem;
  }}/baseline.qcow2";
  systemd.services."libvirtd-guest-test-1" = {
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    script = let
      xml = pkgs.writeText "libvirt-test-1.xml" ''
        <domain type="kvm">
          <name>test-1</name>
          <uuid>UUID</uuid>
          <os>
            <type>hvm</type>
          </os>
          <memory unit="GiB">2</memory>
          <devices>
            <disk type="file" device="disk">
              <driver name="qemu" type="qcow2"/>
              <source file="/var/lib/libvirt/images/test-1.qcow2"/>
              <target dev="vda" bus="virtio"/>
            </disk>
            <graphics type="spice" autoport="yes"/>
            <input type="keyboard" bus="usb"/>
          </devices>
          <features>
            <acpi/>
          </features>
        </domain>
      '';
    in ''
      if ! ${pkgs.libvirt}/bin/virsh vol-key 'test-1.qcow2' --pool default &> /dev/null; then
        cp /etc/virt/base-images/baseline.qcow2 /var/lib/libvirt/images/test-1.qcow2
        ${pkgs.libvirt}/bin/virsh pool-refresh default
        ${pkgs.libvirt}/bin/virsh vol-resize 'test-1.qcow2' 15G --pool default
      fi

      uuid="$(${pkgs.libvirt}/bin/virsh domuuid 'test-1' || true)"
      ${pkgs.libvirt}/bin/virsh define <(sed "s/UUID/$uuid/" '${xml}')
      ${pkgs.libvirt}/bin/virsh start 'test-1'
    '';
    preStop = ''
      ${pkgs.libvirt}/bin/virsh shutdown 'test-1'
      let "timeout = $(date +%s) + 10"
      while [ "$(${pkgs.libvirt}/bin/virsh list --name | grep --count '^test-1$')" -gt 0 ]; do
        if [ "$(date +%s)" -ge "$timeout" ]; then
          # Meh, we warned it...
          ${pkgs.libvirt}/bin/virsh destroy 'test-1'
        else
          # The machine is still running, let's give it some time to shut down
          sleep 0.5
        fi
      done
    '';
  };
}
