# dotshabka

## Deprecation note

This repository is being deprecated.

You can now find my NixOS configuration files at [risson/soxincfg](https://gitlab.com/risson/soxincfg).

You can find the infrastructure files at [lama-corp/infra/infrastructure](https://gitlab.com/lama-corp/infra/infrastructure).

For Gatus configurations, go to <https://gitlab.com/lama-corp/infra/infrastructure/-/tree/main/host_vars/services.fsn.lama.tel/apps/gatus>.

### Shabka configuration files

Directory layout:

- `data`: static data such as IP addresses, SSH keys, etc.;
- `deploy`: deployments files for `morph`;
- `hosts`: configuration for each host;
- `modules`: custom NixOS/home-manager modules;
- `rfcs`: see [rfcs/README.md];
