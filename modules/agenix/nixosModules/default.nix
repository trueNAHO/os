{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];
  options.modules.agenix.nixosModules.enable = lib.mkEnableOption "agenix";
}
