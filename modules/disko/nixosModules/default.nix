{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.disko.nixosModules.disko];
  options.modules.disko.nixosModules.enable = lib.mkEnableOption "disko";

  config = lib.mkIf config.modules.disko.nixosModules.enable {
    assertions = [
      {
        assertion = config.disko.devices != {};

        message = ''
          'disko.devices' is undefined: https://github.com/nix-community/disko
        '';
      }
    ];
  };
}
