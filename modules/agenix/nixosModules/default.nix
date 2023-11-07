{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];
  options.modules.agenix.nixosModules.enable = lib.mkEnableOption "agenix";
  config = lib.mkIf config.modules.agenix.nixosModules.enable {};
}
