{
  config,
  lib,
  ...
}: let
  cfg = config.modules.networking;
in {
  options.modules.networking = {
    enable = lib.mkEnableOption "networking";

    # https://github.com/NixOS/nixpkgs/blob/55ac2a9d2024f15c56adf20da505b29659911da8/nixos/modules/tasks/network-interfaces.nix#L436-L463
    hostName = lib.mkOption {
      default = config.system.nixos.distroId;
      defaultText = lib.literalExpression "config.system.nixos.distroId";

      type =
        lib.types.strMatching
        "^$|^[[:alnum:]]([[:alnum:]_-]{0,61}[[:alnum:]])?$";

      description = lib.mdDoc "Equivalent 'networking.hostName' attribute.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      hostName = cfg.hostName;
      networkmanager.enable = true;
    };
  };
}
