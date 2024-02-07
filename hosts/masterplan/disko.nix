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
              mountOptions = ["umask=0077"];
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

                  "/root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  "/swap" = {
                    mountOptions = [
                      "discard=async"
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                    ];

                    mountpoint = "/swap";
                    swap.swapfile-0.size = "38G";
                  };
                };
              };

              name = "luks";
              passwordFile = passwordFile;
              settings.allowDiscards = true;
              type = "luks";
            };

            size = "100%";
          };
        };

        type = "gpt";
      };

      device = "/dev/nvme0n1";
      type = "disk";
    };
  };
}
