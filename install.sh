#!/usr/bin/env bash

# Set up NixOS with impermanent FAT32 boot, encrypted Btrfs root, and swap
# partitions.

help_message() {
  printf \
    '%b\n' \
    "Usage: $0 -c HARDWARE -d DISK -p PASSWORD -s SWAP_SIZE [options]\n" \
    "Set up NixOS with impermanent FAT32 boot, encrypted Btrfs root, and swap partitions.\n" \
    "Options:" \
    "\t-B BOOT_LABEL\t\tSet the label for the boot partition (default: '$DEFAULT_BOOT_LABEL')" \
    "\t-P PARTITION_SUFFIX\tSet the partition suffix for DISK (default: '$DEFAULT_DISK_PARTITION_SUFFIX', example: 'p')" \
    "\t-R ROOT_LABEL\t\tSet the label for the root partition (default: '$DEFAULT_ROOT_LABEL')" \
    "\t-S SWAP_LABEL\t\tSet the label for the swap partition (default: '$DEFAULT_SWAP_LABEL')" \
    "\t-b BOOT_SIZE\t\tSet the boot partition size (default: '$DEFAULT_BOOT_SIZE')" \
    "\t-c HARDWARE\t\tSet the path within FLAKE_URL to write the hardware configuration file (example: 'hosts/host/harware-configuration.nix')" \
    "\t-d DISK\t\t\tSet the target partitioning device (example: '/dev/nvme0n1')" \
    "\t-h\t\t\tDisplay this help message" \
    "\t-p PASSWORD\t\tSet the LUKS password for the root partition (example: 'PASSWORD')" \
    "\t-s SWAP_SIZE\t\tSet the swap partition size (example: '4GB')" \
    "\t-u FLAKE_URL\t\tSet the flake URL of the NixOS configuration repostitory (default: '$DEFAULT_FLAKE_URL')" \
    "\t-v SUBVOLUME\t\tAdd a Btrfs subvolume on the root partition (default: '${!DEFAULT_BTRFS_SUBVOLUME_PATHS[*]}', example: 'etc/nixos')" \
    "\t-y\t\t\tDisable the confirmation prompt" \
    >&2
}

parse_cli_arguments() {
  while getopts B:P:R:S:b:c:d:hp:s:u:v:y flag; do
    case "$flag" in
      B) BOOT_LABEL="$OPTARG" ;;
      P) DISK_PARTITION_SUFFIX="$OPTARG" ;;
      R) ROOT_LABEL="$OPTARG" ;;
      S) SWAP_LABEL="$OPTARG" ;;
      b) BOOT_SIZE="$OPTARG" ;;
      c) HARDWARE_CONFIG_PATH="$OPTARG" ;;
      d) DISK="$OPTARG" ;;

      h)
        help_message
        exit 0
        ;;

      p) PASSWORD="$OPTARG" ;;
      s) SWAP_SIZE="$OPTARG" ;;
      u) FLAKE_URL="$OPTARG" ;;
      v) BTRFS_SUBVOLUME_PATHS[$OPTARG]="" ;;
      y) PROMPT=0 ;;

      *)
        help_message
        exit 2
        ;;
    esac
  done
}

prompt_confirmation() {
  printf \
    '%b\n' \
    "WARNING!" \
    "========" \
    "This will overwrite data on $DISK irrevocably.\n"

  read -p "Are you sure? (Type 'yes' in capital letters): " -r answer

  if [[ "$answer" != "YES" ]]; then
    printf '%s\n' "Operation aborted." >&2
    exit 4
  fi
}

setup_boot() {
  mkfs.fat -F 32 -n "$BOOT_LABEL" "$physical_boot_partition"
  mkdir --parent "$target_boot_partition"
  mount "$physical_boot_partition" "$target_boot_partition"
}

setup_partitions() {
  parted \
    "$DISK" \
    -- \
    mklabel gpt \
    mkpart ESP fat32 1MB "$BOOT_SIZE" \
    mkpart primary "$BOOT_SIZE" "-$SWAP_SIZE" \
    mkpart primary linux-swap "-$SWAP_SIZE" 100% \
    set 1 esp on
}

setup_root() {
  printf '%s\n' "$PASSWORD" |
    cryptsetup luksFormat "$physical_root_partition"

  printf '%s\n' "$PASSWORD" |
    cryptsetup open "$physical_root_partition" "$ROOT_LABEL"

  mkfs.btrfs "$physical_encrypted_root_partition"

  mkdir --parent "$target_root_partition"

  mount \
    "$physical_encrypted_root_partition" \
    --options compress-force=zstd,noatime,ssd \
    "$target_root_partition"

  for subvolume_path in "${!BTRFS_SUBVOLUME_PATHS[@]}"; do
    subvolume_name="${subvolume_path//\//@}"

    btrfs subvolume create "$target_root_partition/$subvolume_name"
    mkdir --parent "$target_mount_point/$subvolume_path"

    mount \
      "$physical_encrypted_root_partition" \
      --options compress-force=zstd,noatime,ssd,subvol="$subvolume_name" \
      "$target_mount_point/$subvolume_path"
  done
}

setup_swap() {
  mkswap --label "$SWAP_LABEL" "$physical_swap_partition"
  swapon "$physical_swap_partition"
}

main() {
  set -e

  declare -Ar DEFAULT_BTRFS_SUBVOLUME_PATHS=([nix]="")
  readonly DEFAULT_BOOT_LABEL="boot"
  readonly DEFAULT_BOOT_SIZE="512MB"
  readonly DEFAULT_DISK_PARTITION_SUFFIX=""
  readonly DEFAULT_FLAKE_URL="github:trueNAHO/os"
  readonly DEFAULT_ROOT_LABEL="root"
  readonly DEFAULT_SWAP_LABEL="swap"

  declare -A BTRFS_SUBVOLUME_PATHS

  for i in "${!DEFAULT_BTRFS_SUBVOLUME_PATHS[@]}"; do
    BTRFS_SUBVOLUME_PATHS[$i]="${BTRFS_SUBVOLUME_PATHS[$i]}"
  done

  BOOT_LABEL="$DEFAULT_BOOT_LABEL"
  BOOT_SIZE="$DEFAULT_BOOT_SIZE"
  DISK=""
  DISK_PARTITION_SUFFIX="$DEFAULT_DISK_PARTITION_SUFFIX"
  FLAKE_URL="$DEFAULT_FLAKE_URL"
  HARDWARE_CONFIG_PATH=""
  PASSWORD=""
  PROMPT=1
  ROOT_LABEL="$DEFAULT_ROOT_LABEL"
  SWAP_LABEL="$DEFAULT_SWAP_LABEL"
  SWAP_SIZE=""

  parse_cli_arguments "$@"

  if [[
    -z "$DISK" ||
    -z "$HARDWARE_CONFIG_PATH" ||
    -z "$PASSWORD" ||
    -z "$SWAP_SIZE" ]] \
    ; then
    help_message
    exit 3
  fi

  readonly BOOT_LABEL
  readonly BOOT_SIZE
  readonly BTRFS_SUBVOLUME_PATHS
  readonly DISK
  readonly DISK_PARTITION_SUFFIX
  readonly FLAKE_URL
  readonly HARDWARE_CONFIG_PATH
  readonly PASSWORD
  readonly PROMPT
  readonly ROOT_LABEL
  readonly SWAP_LABEL
  readonly SWAP_SIZE

  if ((PROMPT)); then
    prompt_confirmation
  fi

  physical_boot_partition="${DISK}${DISK_PARTITION_SUFFIX}1"
  physical_root_partition="${DISK}${DISK_PARTITION_SUFFIX}2"
  physical_swap_partition="${DISK}${DISK_PARTITION_SUFFIX}3"

  physical_encrypted_root_partition="/dev/mapper/$ROOT_LABEL"

  target_mount_point=/mnt

  target_boot_partition="$target_mount_point/boot"
  target_root_partition=/tmp/root

  target_nixos_config="$target_mount_point/etc/nixos"

  setup_partitions

  mount --types tmpfs none "$target_mount_point"

  setup_boot
  setup_swap
  setup_root

  nix flake clone \
    --dest "$target_nixos_config" \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    "$FLAKE_URL"

  nixos-generate-config \
    --root "$target_mount_point" \
    --show-hardware-config \
    >"$target_nixos_config/$HARDWARE_CONFIG_PATH"
}

main "$@"
