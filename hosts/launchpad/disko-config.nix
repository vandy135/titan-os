# Disko configuration for launchpad host
# NVMe-based system with UEFI boot, btrfs root, and hibernation support
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition - 2GB
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };

            # Swap Partition - 32GB for hibernation
            swap = {
              size = "32G";
              content = {
                type = "swap";
                randomEncryption = false; # Disabled for hibernation support
                resumeDevice = true; # Enable resume from hibernation
              };
            };

            # Btrfs Root Partition - Remaining space
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"]; # Force overwrite existing filesystem
                subvolumes = {
                  # Root subvolume - mounted at /
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };

                  # Home subvolume - user data
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };

                  # Nix store subvolume - optimized for many small files
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };

                  # Log subvolume - system logs
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };

                  # Snapshots subvolume - for backup purposes
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
