# Setting up a ZFS pool on a Unix System

ZFS is a filesystem implementation that can provide increased redundancy and performance over an array of disks.
There is overhead associated with using ZFS. Always consider your system and requirements when choosing to use ZFS.

## Setup


Search for the disks you want to create a ZFS pool on top of by their disk id:

```bash
ls /dev/disk/by-id/ | grep -v part
```

Come up with a suitable disk regex to match them all -- e.g.  `wwn-0x5000c*`


If you have not already, wipe your disks:

```bash
# Wipe the filesystems
for X in $(ls /dev/disk/by-id/<disk-regex>) | grep part) ; do wipefs -a ${X}; done
# Destroy the partition tables
for X in $(ls /dev/disk/by-id/<disk-regex>) | grep part) ; do sgdisk -Z ${X}; done
```

Create the ZFS pool:

```bash
# This is just an example from when I configured 5 x 2 TiB Seagate drives. 
#  Remember to properly research your hardware and requirements before deciding on a proper config!
zpool create <pool-name> -o ashift=12 -O atime=off -O recordsize=1M -O sync=disabled -O compression=on /dev/disk/by-id/<disk-regex>
# It's a great idea to pair with ZFS with an SSD for caching metadata. In my case 128 GiB was sufficient capacity for this.
zpool add <pool-name> -o ashift=12 special /dev/nvme0n1
# Set the special_small_blocks property
zfs set special_small_blocks=32k <pool-name>
```

Congratulations! Your ZFS filesystem should be mounted under `/<pool-name>` on your system :)

Thanks to John Suykerbuyk for very patiently walking me through this
