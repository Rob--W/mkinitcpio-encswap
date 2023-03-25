# mkinitcpio-encswap

`encswap` offers hibernate (aka suspend-to-disk) backed by an encrypted swap
partition. Upon resume, the key is erased and the swap is turned off.

Hibernate ("suspend-to-disk") is a feature that enables the user to power off a
system and boot the system into the same state before shutdown. A hibernated
system does not consume any power, unlike the alternative (suspend-to-RAM).

`encswap` is carefully designed to enable hibernate functionality with minimal
side effects. The swap is only enabled temporarily (at hibernate until resume)
to prevent the RAM's content from being written to disk during normal usage.
The swap space is encrypted with a temporary key.


Warnings:

- `encswap` is designed to support resumption after hibernation, so the "suspend"
  hook and other suspend-related kernel parameters should not be used.

- `encswap` generates a temporary key to encrypt the swap before hibernate, and
  erases the key at suspend. The default location is `/root/encswap.key` and is
  expected to be part of an encrypted volume, unlocked by the "encrypt" hook at
  boot time (requiring a passphrase at boot). To write and erase the key, this
  filesystem must be mounted as writable before hibernation.

- Do NOT modify mounted filesystems between hibernate and resume. This can
  result in data corruption.

- After upgrading the kernel or changing kernel parameters, do not hibernate
  until the next reboot. An incompatible kernel will boot without resuming from
  the hibernation image. As an alternative, use suspend-to-RAM and maintain
  enough power to keep the system suspended to RAM.
 

## How encswap works

This hook initializes support for resuming from an encrypted swapfile for which
the keyfile is located in the encrypted filesystem. The swap device and the
location of the keyfile is configured in /etc/encswap.conf

To use this module, edit /etc/mkinitcpio.conf and add "encswap" to HOOKS,
after "encrypt".

encswap is designed to support resumption after hibernation, so the "suspend"
hook is unnecessary and should not be used. Do not set any suspend-related
kernel parameters.
The encswap.service systemd service is responsible for refreshing a key
and enabling swap before hibernation.

To see this help message, run: `mkinitcpio -H encswap`


## Install

This script was developed for use on ArchLinux.
To build the package, run:

```
makepkg -c
```

To install the built package, run:

```
sudo pacman -U mkinitcpio-encswap-0.1.1-1-any.pkg.tar.xz
```

In order to use the package, you need to edit two configuration files first,
which is explained in more detail below, at "Configuration":

- `/etc/encswap.conf` - to list the partition holding the hibernation file.
- `/etc/mkinitcpio.conf` - to add "encswap" to HOOKS, after "encrypt".

After editing the configuration, rebuild initramfs: `mkinitcpio -p linux`

Finally, reboot to load the new kernel with hibernate support.
Do not try to hibernate before rebooting!


## Configuration

First, find the path to the partition reserved for the encrypted swap partition
that holds the hibernation file. The size of this partition should at least be
the size of your RAM, to make sure that the RAM can be fully written to disk
when you hibernate your system.

If you don't have such a partition yet, create it, e.g. using `cgdisk`. To find
the UUID, run: `lsblk -o name,label,partuuid,partlabel,size,type,mountpoint`
After finding the partition UUID, edit `/etc/encswap.conf` and set `swapdev` to
the path. For example:

```
swapdev=/dev/disk/by-partuuid/655266f2-9f0b-11ed-87f6-7b1bed9fa0c5
```

WARNING: Confirm that the path is correct; choosing the wrong partition can
result in irrecoverable data loss!

The configuration and the hook will only work if "encswap" is part of HOOKS in
/etc/mkinitcpio.conf. Edit that file and add "encswap" after "encrypt" if you
have not done that before.

After updating the configuration, rebuild initramfs: `mkinitcpio -p linux`
