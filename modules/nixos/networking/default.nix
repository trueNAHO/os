{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.nixos.networking;
in {
  imports = [../../agenix/nixosModules];

  options.modules.nixos.networking = {
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

    wpa_gui.enable = lib.mkEnableOption "wpa_gui";
  };

  config = lib.mkIf cfg.enable {
    modules.agenix.nixosModules.enable = true;

    age.secrets = {
      networkingWirelessEnvironmentFile.file = ./environmentFile.age;

      networkingWirelessNetworksEduroamAuthCaCert.file =
        ./eduroamAuthCaCert.age;
    };

    environment.systemPackages =
      lib.mkIf cfg.wpa_gui.enable [pkgs.wpa_supplicant_gui];

    networking = {
      hostName = cfg.hostName;

      wireless = {
        enable = true;
        environmentFile =
          config.age.secrets.networkingWirelessEnvironmentFile.path;

        networks = {
          NETGEAR57-5G.psk = "@NETGEAR57_5G_psk@";
          NETGEAR57.psk = "@NETGEAR57_psk@";

          eduroam.auth = ''
            altsubject_match="DNS:guest.uni.lux;DNS:ise.uni.lu;DNS:sponsor.uni.lux"
            anonymous_identity="@eduroam_anonymous_identity@"
            ca_cert="${config.age.secrets.networkingWirelessNetworksEduroamAuthCaCert.path}"
            eap=TTLS
            group=CCMP TKIP
            identity="@eduroam_identity@"
            key_mgmt=WPA-EAP
            pairwise=CCMP
            password="@eduroam_password@"
            phase2="auth=MSCHAPV2"
          '';
        };

        userControlled.enable = true;
      };
    };
  };
}
