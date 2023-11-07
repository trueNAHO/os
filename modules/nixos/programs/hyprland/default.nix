{
  config,
  lib,
  ...
}: {
  options.modules.nixos.programs.hyprland.enable = lib.mkEnableOption "Hyprland";

  config = lib.mkIf config.modules.nixos.programs.hyprland.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.hyprland.enable = true;
  };
}
