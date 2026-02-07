{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.system.zram;
in {
  options.modules.system.zram = {
    enable = mkEnableOption "zram - Compressed swap in RAM";
    memoryPercent = mkOption {
      type = types.int;
      default = 50;
      description = "Percentage of RAM to use for zram swap";
    };
  };

  config = mkIf cfg.enable {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = cfg.memoryPercent;
    };

    # Tune kernel for zram (prefer zram over disk swap)
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;          # Aggressive swap to zram (appropriate for zram)
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;          # Disable readahead for zram (random access is fine)
    };
  };
}
