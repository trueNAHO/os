{
  config,
  lib,
  ...
}: {
  options.modules.nixos.nix.gc.enable = lib.mkEnableOption "gc";

  config = lib.mkIf config.modules.nixos.nix.gc.enable {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
