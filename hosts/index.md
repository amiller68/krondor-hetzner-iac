# Hosts

Collection of anisble invetory files for targetting specific hosts managed within this repo

## Local

Your local machine

## Hetzner

Organized as:
<host-name> -- should specify ip and path to a user's ssh key on the local machine. Use this for normal users of infrastructure that want to access authorized resources. There can only be one such user on your local machine at the moment.
<host-name>.admin -- should specify ip and path to admin's ssh key on local machine. Only make this available on machines you trust!
# TODO: this is lacking an implementation, I should implement an IPFS service as an example
<host-name>.<service-name> -- should specify ip, path to admin's ssh key, AND appropriate service name. This allows us to administer services as a sudoer, but restrict the privileges they have.

Hetzner servers with static IPs:
- krondor-ax41-nvme
    - info: https://www.hetzner.com/dedicated-rootserver/ax41-nvme/
    - ip: 65.108.195.167
    - host_name: krondor-ax41-nvme
