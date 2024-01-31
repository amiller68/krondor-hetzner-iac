# Krondor Hetzner IaC

I am creating this repository to collect the scripts and playbooks that I find myself running over and over again, and hate doing by hand.
It's also a supreme over indulgence in automating anything I can think of (and trying to get better at ansible).
Hopefully I can use it as a template for one off projects when I might want to implement a subset of the tools described here. In the meantime it also serves as a place for me to catalog and document my experiments with personal, reliable self hosting.

This repository is  primarily is concerned with adminstering provisioned servers and hardware. I chose Hetzner for this project because they are easy to get started with and have a line of great products to handle my needs as they grow. I'm hoping to launch more services on their hardware.

If you want E2E automation of provisioning this repository is not (yet) for you, but Hetnzer Cloud does offer on-demand computer and building blocks like floating IPs, load balancers, and networks. I've decided that all of that is probably over kill for my services but I do want to eventually write boilerplate for provisioning containerized services on Hetzner. 

Scripts assume Ubuntu 22.04 LTS environment at the moment, that's just my go to.

## Dependencies
- Python
- Ansible


See `./docs` for more documentation, walkthroughs, and notes.