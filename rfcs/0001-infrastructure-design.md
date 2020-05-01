---
feature: infrastructure-design
start-date: 2020-04-25
author: Marc 'risson' Schmitt
co-authors:
related-issues:
  - https://gitlab.com/lama-corp/infra/dotshabka/-/merge_requests/41
  - https://gitlab.com/lama-corp/infra/dotshabka/-/merge_requests/43
  - https://gitlab.com/lama-corp/infra/dotshabka/-/merge_requests/46
  - https://gitlab.com/lama-corp/infra/dotshabka/-/merge_requests/48
---

# Summary
[summary]: #summary

Our infrastructure is growing rapidly. The goal here is to define how we shall
structure it and manage it.

# Motivation
[motivation]: #motivation

We used to have most services managed by YunoHost in a single virtual machine
hosted on `duck`. This was okay for us to have something that works, but we
were not able to tweak it. Most of the services hosted there have been or are
being migrated to `duck`, bare-metal. This is starting to show some limitations
as some services are more heavy on the machine than the others. To limit the
usage consumption, we could containerize everything, but to have a nice
production setup, we would have to manage a Kubernetes cluster, which is
currently a non-starter due to its complexity. Instead, we can run those
services in virtual machines, which will than reduce their impact on the host.

# Detailed design
[design]: #detailed-design

The resulting infrastructure would result in a set of primary servers and
virtual machines as follows:

## Network description

In the following subsections, internal IPs refer to IPs in the Wireguard
network, or routed by the hosts to this network, external IPs refer to
world-reachable IPs and local IPs refer to IPs used in the host's region. Local
IPs may be routed by the host from the internal network to the local network.

Ideally, all hosts should be world-reachable via IPv6, however, due to current
limitations imposed by our home ISPs, and the fact that the Wireguard network
provides encryption, we would go with an internal private IPv6 `/48` subnet.

### Internal network

IPv4: `172.28.0.0/16` with a `/24` per primary server.
IPv6: `fd00:7fd7:e9a5::/48` with a `/64` per primary server.

## Primary servers

Those servers will be hosted by Hetzner, or at home. If hosted at Hetzner, they
can be VPSes. Those will also be masters in the Wireguard network, i.e. they
will be peers to other masters, and then forward IPs in their subnet to their
virtual machines and local devices, if any. Ideally, there would be one master
per physical region.

### `kvm-1.srv.fsn`

Hosted at: Hetzner, Falkenstein (fsn), Germany

Internal IP: `172.28.1.1/24` `df00:7fd7:e9a5:1:1::1/64`

External IP: `148.251.50.190/32` `2a01:4f8:202:1097::1/128`

It also holds `148.251.148.232/29` and `2a01:4f8:202:1097::1/64` which are used
to give public IPs to virtual machines.

Currently named `duck`, this server will be responsible for running virtual
machines. There shall not be any applications on it, as it would defeat the
whole purpose of this RFC. It would only manage virtual machines, provision
them, and manage their network. The fact that it holds a public `/29` could
allow us to migrate to a new server without have to change IPs for our public
services.

### `nas.srv.bar`

Hosted at: @risson's home, Barr (bar), France

Local IP: `192.168.44.0/24`

Internal IP: `172.28.2.1/24` `df00:7fd7:e9a5:1:2::1/64`

External IP: none, due to ISP limitations. However, we have a dynamic DNS
service running on this machine, that updates the `bar.lama-corp.space` DNS
record whenever the public IP changes. Moreover, no port is currently forwarded
from the global Internet to this machine.

This machine is responsible for off-site backups. It currently has 3*6TB in a
RAIDZ (equivalent to RAID-5) giving us about 9 TB of storage. As all our
servers' file systems shall be ZFS, we can use the features of this file system
to send snapshots of our servers (this only includes services data, not system
data, as it is reproducible from our servers' configuration). It would also be
an NFS server, for multimedia content, or could act as a drive for an eventual
Nextcloud, but this is currently limited by network bandwidth restrictions.

### `giraffe.srv.nbg`

Hosted at: Hetzner, Nuremberg (nbg), Germany

Internal IP: `172.28.3.1/24` `df00:7fd7:e9a5:1:3::1/64`

External IP: `78.46.241.184/32` `2a01:4f8:c0c:1f9a::1/64`

This server is a VPS that shall be used as a monitoring center. It stores
monitoring data from all our other hosts for a period of 30 days. It could also
act as a second backup SMTP server, in addition to `mail-1.vrt.fsn` and
`mail-2.vrt.fsn`, described below.

## Virtual machines

Those virtual machines would all be running on `kvm-1.srv.fsn`. If our
infrastructure grows, we could then add KVMs and migrate virtual machines to
them.

### `gitlab-1.vrt.fsn`

External IP: `148.251.148.232/32` `2a01:4f8:202:1097::2/128`

Internal IP: `172.28.1.2/32` `df00:7fd7:e9a5:1::2/128`

This machine will run a GitLab instance. It is currently a draft, and will most
likely not be deployed any time soon. Also, it will use our YunoHost instance's
old IP.

### `lewdax.vrt.fsn`

External IP: `148.251.148.233/32` `2a01:4f8:202:1097::3/128`

Currently `lewdax.virt.duck.srv.fsn`. Virtual machine running YunoHost, hosted
for one of risson's friend. Not integrated in our infrastructure.

### `reverse-1.vrt.fsn`

External IP: `148.251.148.238/32` `2a01:4f8:202:1097::8/128`

Internal IP: `172.28.1.8/32` `df00:7fd7:e9a5:1::8/128`

This host will be responsible for proxying all web connections made from the
outside world to our services. It will also handle SSL/TLS termination. It shall
not hold any long-term state apart from the SSL/TLS certificates.

### `mail-1.vrt.fsn`

External IP: `148.251.148.239` `2a01:4f8:202:1097::9/128`

Internal IP: `172.28.1.9/32` `df00:7fd7:e9a5:1::9/128`

Currently `mail-1.duck.srv.fsn`. This host will run a full mail stack, including
Postfix, Dovecot, rspamd, ClamAV and Roundcube. It will be world-reachable for
email ports, however, Roundcube will be proxied by `reverse-1.vrt.fsn`. It
currently is in a testing phase, but ultimately, all emails will be managed by
it.

### `ldap-1.vrt.fsn`

Internal IP: `172.28.1.10/32` `df00:7fd7:e9a5:1::a/128`

Currently `ldap-1.duck.srv.fsn`. This host will run a LDAP server for our
infrastructure wide authentication.

### `postgres-1.vrt.fsn`

Internal IP: `172.28.1.20/32` `df00:7fd7:e9a5:1::14/128`

This host will run a PostgreSQL instance. If it is ever needed, we can deploy
more nodea that will act as slaves.

### `minio-1.vrt.fsn`

Internal IP: `172.28.1.30/32` `df00:7fd7:e9a5:1::1e/128`

This host will run our MinIO S3 instance. More nodes may be added for
replication.

### `web-1.vrt.fsn`

Internal IP: `172.28.1.50/32` `df00:7fd7:e9a5:1::32/128`

This host will hold all web applications. This includes static websites, PHP
websites, Mattermost, Django and Flask websites. Those shall be stateless
(modulo some cache). This virtual machine should be re-deployable easily, which
means that it can easily be split if one of our application has some special
requirements and needs to be separated from the other ones. It will also run
TheFractalBot.

### `nextcloud-1.vrt.fsn`

Internal IP: `172.28.1.51/32` `df00:7fd7:e9a5:1::33/128`

This host will run a Nextcloud instance.

### `gl-runner-1.vrt.fsn`

Tnternal IP: `172.28.1.101/32` `df00:7fd7:e9a5:1::65/128`

This host will run our gitlab runners. For now they will be assigned to
GitLab.com. A new virtual machine for our own GitLab instance may be added.

### `hercules-ci-1.vrt.fsn`

Internal IP: `172.28.1.110/32` `df00:7fd7:e9a5:1::6e/128`

This host will run a Hercules CI instance.

### Personal virtual machines

Personal virtual machines may be added by system administrators for their own
need. However, the resources allocated to those must stay within reasonable
limits.

## Deployment

No deployment shall be made from the hosts themselves. They will be made using
[`morph`](https://github.com/DBCDK/morph). The usage of this tool shall be
documented elsewhere.

## Secrets

Secrets will be stored in a Git repository, hosted on our infrastructure, and
only accessible from inside our infrastructure. Systems administrators shall
backup this repository on off-line storage devices regularly. Secrets will be
deployed with `morph`.

# Drawbacks
[drawbacks]: #drawbacks

This design will put an additional load on `kvm-1.srv.fsn`, due to the fact that it
will be running many full-featured operating systems. The predicted bottleneck
is disk I/O, due to the fact that we are running on old hard drives that are
already having a hard time keeping up. However, this problem can be mitigated
by migrating to a new server, that will have SSDs. This needs additional design
and some feedback on disk space usage once we deploy the proposed
infrastructure.

# Alternatives
[alternatives]: #alternatives

## Bare metal

Everything could stay bare metal, but for reasons mentionned above, it is better
to separate our services.

## VPSes

Hetzner VPSes are pretty cheap. However, no NixOS deployment tools fully
support provisioning VPSes, with or without a ZFS file system, so we would have
to write our own. Moreover, it does not allow for one time purposes workflow
that need a lot of CPU power from the server.

## Kubernetes cluster

Too complicated.

# Unresolved questions
[unresolved]: #unresolved-questions

N/A

# Future work
[future]: #future-work

As mentioned previously, a new server with SSDs may be an ideal solution to a
few of our problems.
