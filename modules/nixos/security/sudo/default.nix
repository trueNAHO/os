{
  config,
  lib,
  ...
}: {
  options.modules.nixos.security.sudo.enable = lib.mkEnableOption "sudo";

  config = lib.mkIf config.modules.nixos.security.sudo.enable {
    security.sudo.extraConfig = "Defaults lecture = never";
  };
}
