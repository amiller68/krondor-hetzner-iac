# ARCHIVED

I think I've taken this pattern as far as I can :).
I've personally moved on to implementing this pattern directly withing projects themselves.
This seems to be more flexible / extensible than maintaining it in one monolithic repo, as this project did (managing my blog, ipfs instance, and personal site on one host).
However this repo may still be helpful to anyone wanting to learn more about scripting python together with ansible and some tricks for doing so.
I hope to take the lessons I've learned here and maybe make something more general purpose and extensible to a wider variety of infrastructure, so stay tuned for more.

# Krondor Hetzner IaC

I am creating this repository to collect the scripts and playbooks that I find myself running over and over again, and hate doing by hand.
It's also a supreme over indulgence in automating anything I can think of (and trying to get better at ansible).
Hopefully I can use it as a template for one off projects when I might want to implement a subset of the tools described here. In the meantime it also serves as a place for me to catalog and document my experiments with personal, reliable self hosting.

This repository is  primarily is concerned with adminstering provisioned servers and hardware. I chose Hetzner for this project because they are easy to get started with and have a line of great products to handle my needs as they grow. I'm hoping to launch more services on their hardware.

If you want E2E automation of provisioning this repository is not (yet) for you, but Hetnzer Cloud does offer on-demand computer and building blocks like floating IPs, load balancers, and networks. I've decided that all of that is probably over kill for my services but I do want to eventually write boilerplate for provisioning containerized services on Hetzner. 

Scripts assume Ubuntu 22.04 LTS environment.

## Dependencies
- Python
- Ansible
- Brew and Rustup (just for installing some packages via the `local` playbooks)

## What actually does this implement?
In order of complexity, this repository includes documentation and scripts for:
- setting up a dedicated server on Hetzner with an administrator
- securing and administering the server
- creating and managing users and services (IPFS, telgram bot, etc)
- load balancer implementation for serving services over HTTPS

See `./docs` for full walkthroughs and notes

## Disclaimer

Please be aware of the following:

- This codebase is continually evolving, and features may be added, modified, or removed at any time without notice.
- It may contain bugs, errors, or vulnerabilities that could compromise the security or stability of your systems.
- Use of the scripts and playbooks provided here is at your own risk, and the author assumes no liability for any damages or issues arising from their use.
- It is recommended to thoroughly review and test any scripts or configurations before deploying them in a production environment.
- Security practices and configurations may not be comprehensive or suitable for all use cases. It is essential to conduct your own security assessments and implement additional measures as needed.

By using this repository, you acknowledge and accept the risks associated with its use and agree to use it responsibly and at your own discretion. Contributions, feedback, and improvements are welcome but should be made with caution and consideration for the aforementioned factors.
