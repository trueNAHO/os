# Masterplan

Optionally, **wipe** and format all **disks** for `masterplan` with
[impermanent](https://grahamc.com/blog/erase-your-darlings) [FAT32 boot,
encrypted Btrfs root, and swap partitions](disko-config.nix) with the following
command. Make sure to [prepare the disk by overwriting it with a stream of
random
bytes](https://wiki.archlinux.org/title/Data-at-rest_encryption#Preparing_the_disk),
by running [`shred --random-source=/dev/urandom --verbose
/dev/nvme0n1`](https://wiki.archlinux.org/title/Securely_wipe_disk#shred):

```bash
(
  set -e

  trap 'rm --force "$disko_config" "$password_file"' EXIT

  disko_config="$(mktemp)"

  curl \
    --output "$disko_config" \
    https://raw.githubusercontent.com/trueNAHO/os/master/hosts/masterplan/disko-config.nix

  password_file="$(mktemp)"

  read -p 'Disk encryption password: ' -rs password
  printf '%s' "$password" >"$password_file"

  nix run \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    github:nix-community/disko \
    -- \
    --arg passwordFile "\"$password_file\"" \
    --mode disko \
    "$disko_config"
)
```

To clone the latest `masterplan` flake to `/mnt/etc/nixos`, run:

```bash
nix flake clone \
  --dest /mnt/etc/nixos \
  --extra-experimental-features flakes \
  --extra-experimental-features nix-command \
  github:trueNAHO/os
```

Optionally, update `masterplan`'s hardware configuration with:

```bash
nixos-generate-config \
  --no-filesystems \
  --root /mnt \
  --show-hardware-config \
  >/mnt/etc/nixos/hosts/masterplan/hardware-configuration.nix
```

Then, install `masterplan` with:

```bash
nixos-install --flake /mnt/etc/nixos#masterplan
```

Finally, run:

```bash
reboot
```
