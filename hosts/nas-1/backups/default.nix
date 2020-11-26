{ config, ... }:

{
  imports = [
    ./borgbackup.nix
  ];

  services.syncoid = {
    enable = true;
    interval = "hourly";
    sshKey = config.sops.secrets.syncoid_ssh_key.path;

    commands = {
      "root@kvm-2.srv.fsn.lama-corp.space:rpool/persist" = {
        target = "rpool/backups/kvm-2.srv.fsn/persist";
        recursive = true;
      };
      "root@kvm-2.srv.fsn.lama-corp.space:rpool/vms/mail-1" = {
        target = "rpool/backups/kvm-2.srv.fsn/vms/mail-1";
        recursive = true;
      };
    };
  };

  sops.secrets.syncoid_ssh_key.sopsFile = ./syncoid_ssh_key.yml;
}
