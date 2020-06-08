# dotshabka

Shabka configuration files

Directory layout:

* `data`: static data such as IP addresses, SSH keys, etc.;
* `deploy`: deployments files for `morph`;
* `hosts`: configuration for each host;
* `modules`: custom NixOS/home-manager modules;
* `profiles`: default configuration depending on the machine type (kvm, virtual
              machine, workstation, laptop, etc.), imported by `hosts`;
* `rfcs`: see [rfcs/README.md];
* `roles`: default configuration for services, mostly imported by `profiles`.
