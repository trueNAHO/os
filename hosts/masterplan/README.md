# Masterplan

To set up `masterplan` with
[impermanent](https://grahamc.com/blog/erase-your-darlings) FAT32 boot,
encrypted Btrfs root, and swap partitions, run the following command. Make sure
to specify a password (`-p PASSWORD`) and disable the confirmation prompt
(`-y`):

```bash
curl https://raw.githubusercontent.com/trueNAHO/os/master/install.sh |
    bash -s -- \
    -P p \
    -c hosts/masterplan/hardware-configuration.nix \
    -d /dev/nvme0n1 \
    -s 38GB \
    -v persistent \
    -v home
```

Then, install `masterplan` with:

```bash
nixos-install --flake /mnt/etc/nixos#masterplan
```

Finally, run:

```bash
reboot
```
