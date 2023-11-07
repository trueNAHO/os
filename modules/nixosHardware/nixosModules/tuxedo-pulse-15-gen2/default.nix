{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nixosHardware.nixosModules.tuxedo-pulse-15-gen2];

  options.modules.nixosHardware.nixosModules.tuxedo-pulse-15-gen2.enable =
    lib.mkEnableOption "tuxedo-pulse-15-gen2";

  config =
    lib.mkIf
    config.modules.nixosHardware.nixosModules.tuxedo-pulse-15-gen2.enable {
      hardware = {
        amdgpu.loadInInitrd = false;
        enableAllFirmware = true;
      };
    };
}
