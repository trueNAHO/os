{
  config,
  lib,
  ...
}: {
  options.modules.nix.settings.experimental-features.enable =
    lib.mkEnableOption "experimental-features";

  config = lib.mkIf config.modules.nix.settings.experimental-features.enable {
    nix.settings.experimental-features = ["flakes" "nix-command"];
    programs.git.enable = true;
  };
}
