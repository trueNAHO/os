{
  config,
  lib,
  ...
}: {
  options.modules.nix.settings.auto-optimise-store.enable =
    lib.mkEnableOption "auto-optimise-store";

  config = lib.mkIf config.modules.nix.settings.auto-optimise-store.enable {
    nix.settings.auto-optimise-store = true;
  };
}
