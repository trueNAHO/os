{
  config,
  lib,
  ...
}: {
  options.modules.security.sudo.enable = lib.mkEnableOption "sudo";

  config = lib.mkIf config.modules.security.sudo.enable {
    security.sudo.extraConfig = "Defaults lecture = never";
  };
}
