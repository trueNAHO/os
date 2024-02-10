{passwordFile ? "/dev/null", ...}: {
  disko.devices = {
    disk.main = {
      content = {
        partitions = {
          ESP = {
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["defaults"];
            };

            size = "512M";
            type = "EF00";
          };

          luks = {
            content = {
              content = {
                type = "btrfs";
                extraArgs = ["-f"];

                subvolumes = {
                  "/persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd"];
                  };

                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };
              };

              name = "luks";
              passwordFile = passwordFile;
              settings.allowDiscards = true;
              type = "luks";
            };

            end = "-38G";
          };

          swap = {
            content = {
              randomEncryption = true;
              resumeDevice = true;
              type = "swap";
            };

            size = "100%";
          };
        };

        type = "gpt";
      };

      device = "/dev/nvme0n1";
      type = "disk";
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["defaults" "mode=755" "size=2G"];
    };
  };
}
