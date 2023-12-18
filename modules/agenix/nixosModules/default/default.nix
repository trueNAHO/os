{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];

  options.modules.agenix.nixosModules.default.enable =
    lib.mkEnableOption "agenix";
}
