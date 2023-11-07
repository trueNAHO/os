{
  config,
  lib,
  ...
}: {
  options.modules.nixos.nix.settings.auto-optimise-store.enable =
    lib.mkEnableOption "auto-optimise-store";

  config = lib.mkIf config.modules.nixos.nix.settings.auto-optimise-store.enable {
    nix.settings.auto-optimise-store = true;
  };
}
