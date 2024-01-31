# krondor-iac 

Series of scripts and tools for setting up and managing dedicated servers on hetzner. Living repository and template for adminsitering my services.

## Dependencies
- Python
- Ansible

# Overview
- Setting up an instance
- Setting up the environment and installing dependencies
- Torrenting datasets
- Running the demo
- Opening up NFS server on generated output

## Setting up the instance

### Installing the image
We are using a Hetzner SX134 instance for the demo.
Hetzner provides a custom provisioning script accessible through their Rescue System.
See [their docs](https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/) for more information.

Our instance should already be setup with / our tooling assumes the following:
- Ubuntu 22.04
- Ability for password-less ssh to a root user (when setting up an admin)


### Demo Setup 
Our instance is already setup with necessary dependencies to run the demo.

[//]: # (Should you need to set up the instance you can run:)

[//]: # ()
[//]: # (```bash)

[//]: # (# Create an admin user)

[//]: # (./scripts/user.sh admin <path_to_public_key>)

[//]: # (```)

[//]: # (```bash)

[//]: # (# Set up the instance)

[//]: # (./scripts/setup.sh)

[//]: # (```)

### Connecting to the instance
We currently have the following Hetzner hosts setup:
- SX134 @ 65.108.139.172

The server is set up with:
- Ubuntu 22.04
- An admin user called `admin` with passwordless sudo access

Configure your user, home dir, and host in `env/env.user`

Adminstrators can log in to the server using the SSH key provided in our secrets repository:
- save the key to `~/.ssh/id_hetzner`
- run `ssh -i ~/.ssh/id_hetzner admin@65.108.139.172`

Adminstrators can set up non-sudo users with SSH keys as well:
- save the public key of the desired user to a file on your control machine
- run `./scripts/user.sh <user> <file_path>` to set up the user

The user will be able to run non-privileged commands and playbooks using their ssh key. This user will also be accessible via ssh using the admin user's key.
The user will be able to run all necessary commands to run the demo (unless otherwise specified).

### Installing Dataprep 
Even as a non-admin user, you can install the `dataprep` tool on the instance.
After appropriately configuring and moving `env/env.user` and `env/env.git` , you can do this with the following commands:
```bash
# Set up the instance
./scripts/install.sh
```
NOTE: We are currently debugging the installation of the `dataprep` tool on the instance. This will not work at the moment.

### Pulling datasets
We use public datasets as a proxy for user data in the demo.

You can configure the datasets you want to pull from the torrent tracker in `env/torrents.txt`.
Our are all sourced from Academic Torrents.

You can start pulling the datasets with the following command:
```bash
# Pull datasets
./scripts/torrent.sh
```

We have already specified ~8.5 TiBs worth or datasets to pull in `env/torrents.txt`.

After running the playbook, you can check the status of the torrents with the following command:
```bash
# ssh into the instance
ssh -i ~/.ssh/id_hetzner <user>@65.108.139.172
# Check the status of the torrents
tmux a
```
You can detach from the session you start with `tmux a` with `Ctrl + b` and then `d`.

## Running the demo

### Packing the datasets

You can start to run the demo with your specified dataset with the following command:
```bash
# Run the demo
./scripts/run.sh
```

This will pack your dataset into a flat, encrypted, and compressed format by running the `dataprep` tool on them.
The packed files will appear in `/home/exports/<your_user>/packed`.

A manifest of the output will be stored in `manifest.json` in your home directory.
This allows you to recover the original files from the packed files. Do not delete this file.

You can check the status of the packing with the following command:
```bash
# ssh into the instance
ssh -i ~/.ssh/id_hetzner <user>@...
# Check the status of the packing
tmux a
```

### Preparing for onboarding

Your onboarder will need to be a reader on the instance.
An admin add them as one with the following command:

```bash
# Add onboarder as a reader
./scripts/reader.sh <onboarder_name> <onboarder_ip_or_hostname>
```

This will give them read access to the NFS server on the instance under a named user and from a specific IP address or hostname.
The server exports the directory `/home/exports` to the onboarder, from which they can access your packed datasets.

Your onboarder might require a list of files and checksums to verify the integrity of the data.
You can generate this with the following command:
```bash
# Generate a csv describing the packed datasets
./scripts/prepare.sh
```

This will generate a csv file in the `/home/exports/<your_user>` directory called `packed.csv`.
This file contains the following (unnamed) columns:
- `checksum`: the checksum of the file (md5)
- `file`: the name of the file

You might have to fiddle with the adjusted ulimit specified in `ansible/utils/prepare_job.sh` to get the prep job to run.
This is because the number of files in the packed dataset is too large for the default ulimit.

### Onboarding

Once you are sure your dataset is ready to be onboarded, contact an admin and your onboarder.
The admin will start the NFS server on the instance and give your onboarder access to the packed datasets.
The onboarder can then pull your packed datsets and onboard them to Filecoin.

## IFTTT

If you would like to be notified when the demo tasks are complete, you can set up an IFTTT webhook.
See `env/env.ifttt` for more details.
