{
  config,
  lib,
  pkgs,
  ...
}: {
  options.modules.services.xserver.displayManager.enable =
    lib.mkEnableOption "the display manager";

  config = lib.mkIf config.modules.services.xserver.displayManager.enable {
    services.xserver = {
      displayManager.lightdm = {
        background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
        enable = true;

        greeters.gtk.theme = {
          package = pkgs.tokyo-night-gtk;
          name = "Tokyonight-Dark-B";
        };
      };

      enable = true;
    };
  };
}
