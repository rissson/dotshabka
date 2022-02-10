{ config, ... }:

{
  services.syncoid = {
    enable = true;
    interval = "hourly";
    sshKey = config.sops.secrets.syncoid_ssh_key.path;

    commands = {
      "root@kvm-2.srv.fsn.lama-corp.space:rpool/persist" = {
        target = "rpool/backups/kvm-2.fsn.lama.tel/persist";
        recursive = true;
      };
      "root@kvm-2.srv.fsn.lama-corp.space:rpool/vms/k3s-1" = {
        target = "rpool/backups/kvm-2.fsn.lama.tel/vms/k3s-1";
        recursive = true;
      };
      "root@kvm-2.srv.fsn.lama-corp.space:rpool/vms/mail-1" = {
        target = "rpool/backups/kvm-2.fsn.lama.tel/vms/mail-1";
        recursive = true;
      };
      "root@kvm-2.srv.fsn.lama-corp.space:rpool/vms/pine" = {
        target = "rpool/backups/kvm-2.fsn.lama.tel/vms/pine";
        recursive = true;
      };
    };
  };

  sops.secrets.syncoid_ssh_key = {
    sopsFile = ./syncoid_ssh_key.yml;
    owner = config.services.syncoid.user;
  };
}
