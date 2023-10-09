{
  config,
  lib,
  ...
}: {
  options.modules.nix.flake.enable = lib.mkEnableOption "flakes";

  config = lib.mkIf config.modules.nix.flake.enable {
    nix.settings.experimental-features = ["flakes" "nix-command"];
    programs.git.enable = true;
  };
}
