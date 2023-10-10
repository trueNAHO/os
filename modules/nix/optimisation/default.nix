{
  config,
  lib,
  ...
}: {
  options.modules.nix.optimisation.enable =
    lib.mkEnableOption "nix optimisations";

  config = lib.mkIf config.modules.nix.optimisation.enable {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      settings.auto-optimise-store = true;
    };
  };
}
