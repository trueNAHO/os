{
  config,
  lib,
  ...
}: {
  options.modules.services.auto-cpufreq.enable =
    lib.mkEnableOption "auto-cpufreq";

  config = lib.mkIf config.modules.services.auto-cpufreq.enable {
    services.auto-cpufreq = {
      enable = true;

      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };

        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}
