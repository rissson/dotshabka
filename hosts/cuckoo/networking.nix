{ ... }:

{
  networking.hostName = "cuckoo"; # Define your hostname.
  networking.domain = "mmd.bar.lama-corp.space";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # TODO: try to make a wireless access point

  networking.useDHCP = false;
  networking.interfaces.enp4s11.useDHCP = true;
  networking.interfaces.wls33.useDHCP = true;
}
